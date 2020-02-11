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

function Base.read(file::BedgraphFile, el::Type=Vector{Bedgraph.Record})
    # Read file using Bedgraph package.
    return open(file.filename, "r") do io
        Bedgraph.read(io, el)
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

function Base.convert(el::Type{Bedgraph.Record}, nt::NamedTuple{(:chrom, :first, :last, :value),Tuple{String,Int64,Int64,R}}) where R <: Real
    return el(nt.chrom, nt.first, nt.last, nt.value)
end

function Base.convert(el::Type{Vector{Bedgraph.Record}}, itr::TableTraitsUtils.TableIterator)
    return convert.(eltype(el), itr)
end

function Vector{Bedgraph.Record}(x::T) :: Vector{Bedgraph.Record} where {T} #TODO: consider formalising Records function in bedgraph (e.g. Bedgraph.Records, Bedgraph.Bedgraph.Records) that returns Vector{Bedgraph.Record}.

    if TableTraits.isiterabletable(x)
        @debug "Vector{Bedgraph.Record}(x) - isiterabletable"
        return getiterator(x) # Note: conversion of the returned table iterator to type Vector{Bedgraph.Record} will be attempted.
    end

    return x # Note: conversion of the returned value x to type Vector{Bedgraph.Record} will be attempted.
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
