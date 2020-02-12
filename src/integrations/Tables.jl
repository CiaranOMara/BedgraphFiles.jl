@debug "BedgraphFiles loading Tables integration."

function Base.convert(el::Type{Vector{Bedgraph.Record}}, itr::Tables.DataValueRowIterator)

    data = collect(itr)

    @debug "Convert Tables.DataValueRowIterator" typeof(data) eltype(data) data

    return convert.(eltype(el), data)
end
