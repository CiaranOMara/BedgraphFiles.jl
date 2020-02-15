@debug "BedgraphFiles loading Tables integration."

function Base.convert(::Type{Vector{T}}, itr::Tables.DataValueRowIterator) where T <: Bedgraph.Record

    @debug "Convert Tables.DataValueRowIterator" eltype(itr) itr

    return collect(T, itr)
end
