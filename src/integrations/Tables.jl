@debug "BedgraphFiles loading Tables integration."

function Base.convert(::Type{Vector{T}}, itr::Tables.DataValueRowIterator) where T <: Bedgraph.Record

    data = collect(itr)
    @debug "Convert Tables.DataValueRowIterator" eltype(itr) itr


    return convert.(T, data)
end
