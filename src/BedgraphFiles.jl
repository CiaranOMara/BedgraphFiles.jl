__precompile__()

module BedgraphFiles

using FileIO
using Requires

using Bedgraph

using IteratorInterfaceExtensions, TableTraits, TableTraitsUtils
using TableShowUtils

import IterableTables


function __init__()
    @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" include(joinpath(@__DIR__, "integrations","DataFrames.jl"))
end

const BedgraphFileFormat = File{format"bedGraph"}

struct BedgraphFile
    filename::String
    keywords
end

function Base.show(io::IO, source::BedgraphFile)
    TableShowUtils.printtable(io, getiterator(source), "bedGraph file")
end

function Base.read(file::BedgraphFile, type = Vector{Bedgraph.Record{Float64}})
    # Read file using Bedgraph package.
    return open(file.filename, "r") do io
        Bedgraph.read(io, type)
    end
end

function load(f::BedgraphFileFormat; args...)
    return BedgraphFile(f.filename, args)
end

IteratorInterfaceExtensions.isiterable(x::BedgraphFile) = true
TableTraits.isiterabletable(x::BedgraphFile) = true
IteratorInterfaceExtensions.isiterable(x::Vector{Bedgraph.Record{<:Real}}) = true #Note: Vector{Bedgraph.Record} is iterable by default.
TableTraits.isiterabletable(x::Vector{Bedgraph.Record{<:Real}}) = true

function IteratorInterfaceExtensions.getiterator(records::Vector{Bedgraph.Record{R}}) where R <: Real

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

    records = read(file) #TODO: Generate iterator from first record?

    it = getiterator(records)

    return it
end

function Base.collect(x::BedgraphFile)
    return collect(getiterator(x))
end

function _Records(x, r::Type{R}) :: Vector{Bedgraph.Record{R}} where R <: Real #TODO: consider formalising Records function in bedgraph (e.g. Bedgraph.Records, Bedgraph.Bedgraph.Records) that returns Vector{Bedgraph.Record}.
    cols, names = create_columns_from_iterabletable(x, na_representation=:missing)

    return Bedgraph.Record{R}.(cols[1], cols[2], cols[3], cols[4])
end

function Vector{Bedgraph.Record{R}}(x::T) :: Vector{Bedgraph.Record{R}} where {T, R<:Real} #TODO: consider formalising Records function in bedgraph (e.g. Bedgraph.Records, Bedgraph.Bedgraph.Records) that returns Vector{Bedgraph.Record}.

    if TableTraits.isiterabletable(x)
        @debug "Vector{Bedgraph.Record}(x) - isiterabletable"
        return _Records(x, R)
    end

    return x #Note: returned x will be converted to type Vector{Bedgraph.Record}.
end

# function Vector{Bedgraph.Record}(x)
#     return Vector{Bedgraph.Record{Float64}}(x)
# end


function save(file::BedgraphFileFormat, header::Bedgraph.BedgraphHeader, records::Vector{Bedgraph.Record{<:Real}})

    write(file.filename, header, records)

    return records #Note: this return is useful when piping (e.g., records = some_operation | save(file)).
end

function save(file::BedgraphFileFormat, records::Vector{Bedgraph.Record{<:Real}}; bump_forward = true)

    sort!(records)

    header = Bedgraph.generate_basic_header(records, bump_forward = bump_forward) #TODO: consolidate header generation and determine whether there is a need for bump_forward.

    return save(file, header, records)
end

function save(file::BedgraphFileFormat, data; bump_forward = true)

    it = getiterator(data)

    records = Vector{Bedgraph.Record{Float64}}(it)

    save(file, records, bump_forward = bump_forward)

    return data #Note: this return is usful when piping.
end

end # module
