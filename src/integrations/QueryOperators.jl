@debug "BedgraphFiles loading QueryOperators integration."

function Base.convert(el::Type{Vector{Bedgraph.Record}}, query::QueryOperators.Enumerable)

    data = collect(query)

    @debug "Convert QueryOperators.Enumerable" typeof(data) eltype(data) data

    return convert.(eltype(el), data)
end
