__precompile__()

module BedgraphFiles

using Bedgraph, TableTraits, IterableTables, DataValues, DataFrames
using FileIO

# try add_format(format"bedGraph", (), [".bedgraph"], [:BedgraphFiles]) end # TODO: Remove once BedgraphFiles is registered with FileIO.

BedgraphFile = File{format"bedGraph"}

function load(file::BedgraphFile)
    return BedgraphFile(file.filename)
end

TableTraits.isiterable(x::BedgraphFile) = true
TableTraits.isiterabletable(x::BedgraphFile) = true

function TableTraits.getiterator(file::BedgraphFile)

    # Read file using bedgraph package.
    tracks = open(file, "r") do stream
        Bedgraph.readTracks(stream.io)
    end

    # Pack tracks into DataFrame.
    df = DataFrame( chrom = Vector{String}() , chromStart = Vector{Int}(), chromEnd = Vector{Int}(), dataValue = Vector{Float64}())

    for track in tracks # Note: Track data format is chrom chrom_start chrom_end data_value.
        append!(df, DataFrame(chrom = track.chrom, chromStart = track.chrom_start, chromEnd = track.chrom_end, dataValue = track.data_value))
    end

    it = getiterator(df)

    return it
end

function save(file::BedgraphFile, data; bump_forward = true)
    isiterabletable(data) || error("Can't write this data to bedGraph file.")

    it = getiterator(data)

    df = DataFrame(it)

    # Pack DataFrame in to a vector of type track.
    tracks = Vector{Track}()

    for row in eachrow(df)
        push!(tracks, Track(row[1], row[2], row[3], row[4])) # Note: using index to allow flexible column names.
    end

    return save(file, tracks, bump_forward = bump_forward)
end

function save(file::BedgraphFile, tracks::Vector{Bedgraph.Track}; bump_forward = true)

    header = Bedgraph.BedgraphHeader( Bedgraph.generateBasicHeader(tracks, bump_forward = bump_forward) )

    return save(file, header, tracks)
end

function save(file::BedgraphFile, header::Bedgraph.BedgraphHeader, tracks::Vector{Bedgraph.Track})

    open(file, "w") do stream
        write(stream.io, header)
        write(stream.io, tracks)
    end

end

end # module
