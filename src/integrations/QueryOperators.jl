@debug "BedgraphFiles loading QueryOperators integration."

function Base.convert(::Type{Vector{T}}, query::QueryOperators.Enumerable) where T <: Bedgraph.Record

    data = collect(query)
    @debug "Convert QueryOperators.Enumerable" eltype(query) query


    return convert.(T, data)
end
