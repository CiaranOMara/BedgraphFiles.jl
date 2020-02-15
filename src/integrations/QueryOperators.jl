@debug "BedgraphFiles loading QueryOperators integration."

function Base.convert(::Type{Vector{T}}, query::QueryOperators.Enumerable) where T <: Bedgraph.Record

    @debug "Convert QueryOperators.Enumerable" eltype(query) query

    return collect(T, query)
end
