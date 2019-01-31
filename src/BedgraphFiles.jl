__precompile__()

module BedgraphFiles
using FileIO

using Bedgraph
using DataFrames

using IteratorInterfaceExtensions, TableTraits, TableTraitsUtils
using TableShowUtils

import IterableTables


const BedgraphFileFormat = File{format"bedGraph"}

struct BedgraphFile
    filename::String
    keywords
end

function Base.convert(::Type{Vector{Bedgraph.Record}}, df::DataFrame) :: Vector{Bedgraph.Record}

    records = Vector{Bedgraph.Record}(undef, size(df)[1])

    for (i, row) in enumerate(eachrow(df))
        records[i] =  Bedgraph.Record(row[1], row[2], row[3], row[4]) # Note: using index to allow flexible column names.
    end

    return records
end

function Base.show(io::IO, source::BedgraphFile)
    TableShowUtils.printtable(io, getiterator(source), "bedGraph file")
end

function load(f::BedgraphFileFormat; args...)
    return BedgraphFile(f.filename, args)
end

IteratorInterfaceExtensions.isiterable(x::BedgraphFile) = true
TableTraits.isiterabletable(x::BedgraphFile) = true

function _loaddata(path)
    # Read file using bedgraph package.
    return open(path, "r") do io
        Bedgraph.readRecords(io)
    end
end

function IteratorInterfaceExtensions.getiterator(file::BedgraphFile)

    records = _loaddata(file.filename)

    # Pack records into DataFrame.
    df = DataFrame(
        chrom = Bedgraph.chrom.(records)::Vector{String},
        first = first.(records)::Vector{Int},
        last = last.(records)::Vector{Int},
        value = Bedgraph.value.(records)
    )

    it = getiterator(df)

    return it
end

function Base.collect(x::BedgraphFile)
    return collect(getiterator(x))
end

function save(file::BedgraphFileFormat, header::Bedgraph.BedgraphHeader, records::Vector{Bedgraph.Record})
    write(file.filename, header, records)
end

function save(file::BedgraphFileFormat, records::Vector{Bedgraph.Record}; bump_forward = true)

    #TODO: bump_forward records.

    sort!(records)

    header = Bedgraph.generateBasicHeader(records, bump_forward = bump_forward)

    return save(file, header, records)
end

function save(file::BedgraphFileFormat, data; bump_forward = true)
    isiterabletable(data) || error("Can't write this data to bedGraph file.")

    it = getiterator(data)

    df = DataFrame(it)

    # Pack DataFrame in to a vector of type record.
    records = convert(Vector{Bedgraph.Record}, df)
    return save(file, records, bump_forward = bump_forward)

end

end # module
