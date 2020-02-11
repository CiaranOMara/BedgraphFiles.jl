@testset "GenomicFeatures" begin

    using GenomicFeatures


    # Test conversions.
    @test GenomicFeatures.Interval("chr1", 1, 1) == convert(GenomicFeatures.Interval{Nothing}, Bag.record)
    @test GenomicFeatures.Interval("chr1", 1, 1, '?', 0.0) == convert(GenomicFeatures.Interval{Float64}, Bag.record)
    @test GenomicFeatures.Interval("chr1", 1, 1, '?', 0) == convert(GenomicFeatures.Interval{Int64}, Bag.record)


    # Test conversion to IntervalCollection{Nothing}
    col = convert(GenomicFeatures.IntervalCollection{Nothing}, Bag.records)

    @test  GenomicFeatures.IntervalCollection{Nothing}(Bag.records) == convert(GenomicFeatures.IntervalCollection{Nothing}, Bag.records)
    @test  GenomicFeatures.IntervalCollection{Float64}(Bag.records) == convert(GenomicFeatures.IntervalCollection{Float64}, Bag.records)


    @test col == GenomicFeatures.IntervalCollection{Nothing}(load(Bag.file))
    @test col == GenomicFeatures.IntervalCollection{Nothing}(load(Bag.file_headerless))

    @test col == load(Bag.file) |> GenomicFeatures.IntervalCollection{Nothing}
    @test col == load(Bag.file_headerless) |> GenomicFeatures.IntervalCollection{Nothing}


    # Test conversion to IntervalCollection{Float64}.
    col = convert(GenomicFeatures.IntervalCollection{Float64}, Bag.records)

    @test col == GenomicFeatures.IntervalCollection{Float64}(load(Bag.file))
    @test col == GenomicFeatures.IntervalCollection{Float64}(load(Bag.file_headerless))

    @test col == load(Bag.file) |> GenomicFeatures.IntervalCollection{Float64}
    @test col == load(Bag.file_headerless) |> GenomicFeatures.IntervalCollection{Float64}

    @test Bag.records == convert(Vector{Bedgraph.Record}, col)
    @test Bag.records == Vector{Bedgraph.Record}(col)


    # Test saving IntervalCollection{Float64}.
    save(Bag.tmp_output_path, col) #Note: uses col from previous conversion to IntervalCollection{Float64} tests.

    @test Bag.records == Vector{Bedgraph.Record}(load(Bag.tmp_output_path))
    @test Bag.records == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}

    col |> save(Bag.tmp_output_path) #Note: uses col from previous conversion to IntervalCollection{Float64} tests.

    @test Bag.records == Vector{Bedgraph.Record}(load(Bag.tmp_output_path))
    @test Bag.records == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}


    # Test saving IntervalCollection{Nothing}.
    col2 = IntervalCollection([Interval("chr1", i, i + 99) for i in 1:100:10000])
    @test IntervalCollection{Nothing} == typeof(col2)

    save(Bag.tmp_output_path, col2)
    @test col2 == IntervalCollection{Nothing}(load(Bag.tmp_output_path))
    @test col2 == load(Bag.tmp_output_path) |> IntervalCollection{Nothing}

end #testset GenomicFeatures
