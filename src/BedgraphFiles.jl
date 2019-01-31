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

function Base.convert(::Type{Bedgraph.Record}, row::DataFrameRow) :: Bedgraph.Record
    return Bedgraph.Record(row[1], row[2], row[3], row[4]) # Note: using index to allow flexible column names.
end

function Base.convert(::Type{Vector{Bedgraph.Record}}, df::DataFrame) :: Vector{Bedgraph.Record}

    records = Vector{Bedgraph.Record}(undef, size(df)[1])

    for (i, row) in enumerate(eachrow(df))
        records[i] = convert(Bedgraph.Record, row)
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
IteratorInterfaceExtensions.isiterable(x::Vector{Bedgraph.Record}) = true #Note: Vector{Bedgraph.Record} is iterable by default.
TableTraits.isiterabletable(x::Vector{Bedgraph.Record}) = true


function _loaddata(path) :: Vector{Bedgraph.Record}
    # Read file using bedgraph package.
    return open(path, "r") do io
        Bedgraph.readRecords(io)
    end
end

function IteratorInterfaceExtensions.getiterator(records::Vector{Bedgraph.Record})

    columns = [
        Bedgraph.chrom.(records),
        Bedgraph.first.(records),
        Bedgraph.last.(records),
        Bedgraph.value.(records)
    ]

    names = Symbol[:chrom, :first, :last, :value]

    it = TableTraitsUtils.create_tableiterator(columns, names)

    return it
end

function IteratorInterfaceExtensions.getiterator(file::BedgraphFile)

    records = _loaddata(file.filename)

    it = getiterator(records)

    return it
end

function Base.collect(x::BedgraphFile)
    return collect(getiterator(x))
end

function _Records(x) :: Vector{Bedgraph.Record} #TODO: consider formalising Records function in bedgraph (e.g. Bedgraph.Records, Bedgraph.Bedgraph.Records) that returns Vector{Bedgraph.Record}.
    cols, names = create_columns_from_iterabletable(x, na_representation=:missing)

    return convert(Vector{Bedgraph.Record}, cols[1], cols[2], cols[3], cols[4])
end

function Vector{Bedgraph.Record}(x::AbstractVector{T}) :: Vector{Bedgraph.Record} where {T<:NamedTuple}
    @debug "Vector{Bedgraph.Record}(x::AbstractVector{T})"
    return  _Records(x)
end

function Vector{Bedgraph.Record}(x::T) :: Vector{Bedgraph.Record} where {T} #TODO: consider formalising Records function in bedgraph (e.g. Bedgraph.Records, Bedgraph.Bedgraph.Records) that returns Vector{Bedgraph.Record}.

    if TableTraits.isiterabletable(x)
        @debug "Vector{Bedgraph.Record}(x) - isiterabletable"
        return _Records(x)
    else
        @debug "Vector{Bedgraph.Record}(x) - converting"
        return convert(Vector{Bedgraph.Record}, x)
    end
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

    it = getiterator(data)

    records = Vector{Bedgraph.Record}(it)

    return save(file, records, bump_forward = bump_forward)
end

end # module
