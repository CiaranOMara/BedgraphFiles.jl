@info "BedgraphFiles loading GenomicFeatures integration."

function Base.convert(::Type{Bedgraph.Record}, interval::GenomicFeatures.Interval{Nothing}, null_value=1) :: Bedgraph.Record

    return Bedgraph.Record(
        GenomicFeatures.seqname(interval),
        GenomicFeatures.leftposition(interval),
        GenomicFeatures.rightposition(interval),
        null_value #Note: the default null value replacement of 0 is not useful as it does not show in IGV.
    )

end

function Base.convert(::Type{Bedgraph.Record}, interval::GenomicFeatures.Interval{T}) where {T<:Real}

    return Bedgraph.Record(
        GenomicFeatures.seqname(interval),
        GenomicFeatures.leftposition(interval),
        GenomicFeatures.rightposition(interval),
        GenomicFeatures.metadata(interval)
    )

end

function Base.convert(type::Type{Vector{Bedgraph.Record}}, data::Union{GenomicFeatures.IntervalCollection{T}, Vector{GenomicFeatures.Interval{T}}}) where T
	return convert.(eltype(type), data)
end

function Base.convert(::Type{GenomicFeatures.Interval{Nothing}}, record::Bedgraph.Record)

    return GenomicFeatures.Interval(
        record.chrom,
        record.first,
        record.last
    )
end

function Base.convert(::Type{GenomicFeatures.Interval{T}}, record::Bedgraph.Record) :: GenomicFeatures.Interval{T} where {T<:Real}

    return GenomicFeatures.Interval(
        record.chrom,
        record.first,
        record.last,
        '?',
        convert(T, record.value)
    )
end

function Base.convert(type::Type{Vector{GenomicFeatures.Interval{T}}}, records::Vector{Bedgraph.Record}) :: Vector{GenomicFeatures.Interval{T}} where {T<:Union{Nothing, Real}}

    # vec = Vector{GenomicFeatures.Interval{T}}(undef, length(records))
	#
    # for (i, record) in enumerate(records)
    #     interval = convert(GenomicFeatures.Interval{T}, record)
    #     vec[i] = interval
    # end
	#
    # return vec

	return convert.(eltype(type), records)
end

function Base.convert(type::Type{GenomicFeatures.IntervalCollection{T}}, records::Vector{Bedgraph.Record}) :: GenomicFeatures.IntervalCollection{T} where {T<:Union{Nothing, Real}}

	vec = convert.(eltype(type), records)

    return type(vec)
end

function Base.convert(::Type{Vector{GenomicFeatures.Interval{T}}}, file::BedgraphFiles.BedgraphFile) :: Vector{GenomicFeatures.Interval{T}} where {T<:Union{Nothing, Real}}

    records = Vector{Bedgraph.Record}(file)

    return convert(Vector{GenomicFeatures.Interval{T}}, records)

end

function Base.convert(::Type{GenomicFeatures.IntervalCollection{T}}, file::BedgraphFiles.BedgraphFile) :: GenomicFeatures.IntervalCollection{T} where {T<:Union{Nothing, Real}}

    vec = convert(Vector{GenomicFeatures.Interval{T}}, file) #Note: we assume data is in the correct order.

    return GenomicFeatures.IntervalCollection{T}(vec)

end

function GenomicFeatures.IntervalCollection{T}(x) :: GenomicFeatures.IntervalCollection{T} where T

	vec = convert(Vector{GenomicFeatures.Interval{T}}, x)

	return GenomicFeatures.IntervalCollection(vec)

end
