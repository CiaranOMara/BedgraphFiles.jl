@debug "BedgraphFiles loading GenomicFeatures integration."

function Base.convert(::Type{Bedgraph.Record}, interval::GenomicFeatures.Interval{Nothing})

    return Bedgraph.Record(
        GenomicFeatures.seqname(interval),
        GenomicFeatures.leftposition(interval),
        GenomicFeatures.rightposition(interval),
        0
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

function Base.convert(::Type{Vector{Bedgraph.Record}}, collection::GenomicFeatures.IntervalCollection)

    records = Vector{Bedgraph.Record}(undef, length(collection))

    for (i, interval) in enumerate(collection)

        record = convert(Bedgraph.Record, interval)

    	records[i] = record
    end

    return records
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

function Base.convert(::Type{GenomicFeatures.IntervalCollection{T}}, records::Vector{Bedgraph.Record}) :: GenomicFeatures.IntervalCollection{T} where {T<:Union{Nothing, Real}}

    col = GenomicFeatures.IntervalCollection{T}()

    for record in records
        interval = convert(GenomicFeatures.Interval{T}, record)
        push!(col, interval)
    end

    return col
end

function Base.convert(::Type{GenomicFeatures.IntervalCollection{T}}, file::BedgraphFiles.BedgraphFile) :: GenomicFeatures.IntervalCollection{T} where {T<:Union{Nothing, Real}}

    open(file.filename, "r") do io

        col = GenomicFeatures.IntervalCollection{T}()

        while !eof(io)
            record = Bedgraph.readRecord(io)
            if record != nothing
                interval = convert(GenomicFeatures.Interval{T}, record)
                push!(col, interval)
            end
        end

        return col

    end

end

function GenomicFeatures.IntervalCollection{T}(x) :: GenomicFeatures.IntervalCollection{T} where {T<:Union{Nothing, Real}}
    return convert(GenomicFeatures.IntervalCollection{T}, x)
end
