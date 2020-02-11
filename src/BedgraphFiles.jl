__precompile__()

module BedgraphFiles

using FileIO
using Requires

using Bedgraph

using IteratorInterfaceExtensions, TableTraits, TableTraitsUtils
using TableShowUtils

import IterableTables


function __init__()
    @require GenomicFeatures="899a7d2d-5c61-547b-bef9-6698a8d05446" include(joinpath(@__DIR__, "integrations","GeonomicFeatures.jl"))
    @require Tables="bd369af6-aec1-5ad0-b16a-f7cc5008161c" include(joinpath(@__DIR__, "integrations","Tables.jl"))
    @require QueryOperators="2aef5ad7-51ca-5a8f-8e88-e75cf067b44b" include(joinpath(@__DIR__, "integrations","QueryOperators.jl"))
end

const BedgraphFileFormat = File{format"bedGraph"}

struct BedgraphFile
    filename::String
    keywords
end

function Base.show(io::IO, source::BedgraphFile)
    TableShowUtils.printtable(io, getiterator(source), "bedGraph file")
end

function Base.read(file::BedgraphFile, type::Type = Vector{Bedgraph.Record}) :: Vector{Bedgraph.Record}
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
IteratorInterfaceExtensions.isiterable(x::Vector{Bedgraph.Record}) = true #Note: Vector{Bedgraph.Record} is iterable by default.
TableTraits.isiterabletable(x::Vector{Bedgraph.Record}) = true

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

    records = read(file) #TODO: create stream iterator.

    it = getiterator(records)

    return it
end

function Base.collect(x::BedgraphFile)
    return collect(getiterator(x))
end

# function _Records(x) :: Vector{Bedgraph.Record} #TODO: consider formalising Records function in bedgraph (e.g. Bedgraph.Records, Bedgraph.Bedgraph.Records) that returns Vector{Bedgraph.Record}.
#     cols, names = create_columns_from_iterabletable(x, na_representation=:missing)
#
#     return Bedgraph.Record.(cols[1], cols[2], cols[3], cols[4])
# end

function Base.convert(type::Type{Bedgraph.Record}, nt::NamedTuple{(:chrom, :first, :last, :value),Tuple{String,Int64,Int64,R}}) where R <: Real
    return type(nt.chrom, nt.first, nt.last, nt.value)
end

function Base.convert(type::Type{Bedgraph.Record}, nt::NamedTuple{NTuple{4,Symbol},Tuple{String,Int64,Int64,R}}) where R <: Real
    return type(nt[1], nt[2], nt[3], nt[4])
end

function Base.convert(type::Type{Vector{Bedgraph.Record}}, itr::TableTraitsUtils.TableIterator)
    return convert.(eltype(type), itr)
end

function Vector{Bedgraph.Record}(x::T) :: Vector{Bedgraph.Record} where {T} #TODO: consider formalising Records function in bedgraph (e.g. Bedgraph.Records, Bedgraph.Bedgraph.Records) that returns Vector{Bedgraph.Record}.

    if TableTraits.isiterabletable(x)
        @debug "Vector{Bedgraph.Record}(x) - isiterabletable"
        # return _Records(x)
        return getiterator(x) #
    end

    return x #Note: returned x will be converted to type Vector{Bedgraph.Record}.
end

function save(file::BedgraphFileFormat, header::Bedgraph.BedgraphHeader, records::Vector{Bedgraph.Record})

    write(file.filename, header, records)

    return records #Note: this return is useful when piping (e.g., records = some_operation | save(file)).
end

function save(file::BedgraphFileFormat, records::Vector{Bedgraph.Record}; bump_forward = true)

    sort!(records)

    header = Bedgraph.generateBasicHeader(records, bump_forward = bump_forward) #TODO: consolidate header generation and determine whether there is a need for bump_forward.

    return save(file, header, records)
end

function save(file::BedgraphFileFormat, data; bump_forward = true)

    records = Vector{Bedgraph.Record}(data)

    save(file, records, bump_forward = bump_forward)

    return data #Note: this return is usful when piping.
end

end # module
