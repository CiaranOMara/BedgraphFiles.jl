@debug "BedgraphFiles loading GenomicFeatures integration."

function Base.convert(::Type{Bedgraph.Record}, interval::GenomicFeatures.Interval{Nothing}, null_value=1) :: Bedgraph.Record

    return Bedgraph.Record(
        GenomicFeatures.seqname(interval),
        GenomicFeatures.leftposition(interval),
        GenomicFeatures.rightposition(interval),
        null_value #Note: the default null value replacement of 0 is not useful as it does not show in IGV.
    )
end

function Base.convert(::Type{Bedgraph.Record}, interval::GenomicFeatures.Interval{<:Real})

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

function Base.convert(::Type{GenomicFeatures.Interval{T}}, record::Bedgraph.Record) where {T<:Real}

    return GenomicFeatures.Interval(
        record.chrom,
        record.first,
        record.last,
        '?',
        convert(T, record.value)
    )
end

function Base.convert(type::Type{Vector{GenomicFeatures.Interval{T}}}, records::Vector{Bedgraph.Record}) where T
	return convert.(eltype(type), records)
end

function Base.convert(type::Type{GenomicFeatures.IntervalCollection{T}}, records::Vector{Bedgraph.Record}) where T

	vec = convert.(eltype(type), records)

    return type(vec)
end

function Base.convert(type::Type{Vector{GenomicFeatures.Interval{T}}}, file::BedgraphFiles.BedgraphFile) where T

    records = Vector{Bedgraph.Record}(file)

    return convert(type, records)
end

function Base.convert(type::Type{GenomicFeatures.IntervalCollection{T}}, file::BedgraphFiles.BedgraphFile) where T

	records = read(file)

    return type(records)
end

function GenomicFeatures.IntervalCollection{T}(x) where T

	vec = convert(Vector{GenomicFeatures.Interval{T}}, x)

	return GenomicFeatures.IntervalCollection(vec)
end
