__precompile__()

module BedgraphFiles

using FileIO

using Bedgraph

using IteratorInterfaceExtensions, TableTraits, TableTraitsUtils
using TableShowUtils

import IterableTables

const BedgraphFileFormat = File{format"bedGraph"}

struct BedgraphFile
    filename::String
    keywords
end

function Base.show(io::IO, source::BedgraphFile)
    TableShowUtils.printtable(io, getiterator(source), "bedGraph file")
end

function Base.read(file::BedgraphFile, ::Type{T}=Vector{Bedgraph.Record}) where T
    # Read file using Bedgraph package.
    return open(file.filename, "r") do io
        Bedgraph.read(io, T)
    end
end

function load(f::BedgraphFileFormat; args...)
    return BedgraphFile(f.filename, args)
end

IteratorInterfaceExtensions.isiterable(x::BedgraphFile) = true
TableTraits.isiterabletable(x::BedgraphFile) = true
IteratorInterfaceExtensions.isiterable(x::Vector{<:Bedgraph.Record}) = true #Note: Vector{Bedgraph.Record} is iterable by default.
TableTraits.isiterabletable(x::Vector{<:Bedgraph.Record}) = true

function IteratorInterfaceExtensions.getiterator(records::Vector{<:Bedgraph.Record})

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

function Base.collect(T::Type, x::BedgraphFile)
    return collect(T, getiterator(x))
end

function Base.convert(::Type{T}, nt::NamedTuple{(:chrom, :first, :last, :value),Tuple{String,Int64,Int64,R}}) where {R <: Real, T<: Bedgraph.Record}
    @debug "Convert - strict."
    return T(nt.chrom, nt.first, nt.last, nt.value)
end

function Base.convert(::Type{T}, nt::NamedTuple{names,Tuple{String,Int64,Int64,R}}) where {R <: Real, names, T<: Bedgraph.Record}
    @debug "Convert - names."
    return T(nt[1], nt[2], nt[3], nt[4])
end

function Vector{T}(x) where {T <: Bedgraph.Record}
    return collect(T, getiterator(x))
end

function save(file::BedgraphFileFormat, header::Bedgraph.BedgraphHeader, records::Vector{<:Bedgraph.Record})

    write(file.filename, header, records)

    return records #Note: this return is useful when piping (e.g., records = some_operation | save(file)).
end

function save(file::BedgraphFileFormat, records::Vector{<:Bedgraph.Record}; bump_forward = true)

    sort!(records)

    header = Bedgraph.generateBasicHeader(records, bump_forward = bump_forward) #TODO: consolidate header generation and determine whether there is a need for bump_forward.

    return save(file, header, records)
end

function save(file::BedgraphFileFormat, data; bump_forward = true)

    records = collect(Bedgraph.Record, getiterator(data))

    save(file, records, bump_forward = bump_forward)

    return data #Note: this return is usful when piping.
end

end # module
