using FileIO, BedgraphFiles
using Bedgraph

using IteratorInterfaceExtensions
using TableTraits

using Test
using Logging

# old_logger = global_logger(ConsoleLogger(stdout, Logging.Debug))

module Bag

    using Bedgraph

    const chroms = ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
    const firsts = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
    const lasts = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
    const values = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

    const record = Bedgraph.Record("chr1", 1, 1, 0)
    const records = Bedgraph.Record.(Bag.chroms, Bag.firsts, Bag.lasts, Bag.values)

    const file = joinpath(@__DIR__, "data.bedgraph")
    const file_headerless = joinpath(@__DIR__, "data-headerless.bedgraph")

    const tmp_output_path = tempname() * ".bedgraph"

end # module Bag


using .Bag


@testset "BedgraphFiles" begin

    @test isfile(Bag.file) == true
    @test isfile(Bag.file_headerless) == true

    # Load tests.
    loader = load(Bag.file)
    @test IteratorInterfaceExtensions.isiterable(loader) == true
    @test TableTraits.isiterabletable(loader) == true

    loaded = Vector{Bedgraph.Record}(loader)
    @test Vector{Bedgraph.Record} == typeof(loaded)

    loader_from_headerless = load(Bag.file_headerless)
    @test isiterable(loader_from_headerless) == true
    @test TableTraits.isiterabletable(loader_from_headerless) == true

    loaded_from_headerless = Vector{Bedgraph.Record}(loader_from_headerless)
    @test Vector{Bedgraph.Record} == typeof(loaded_from_headerless)

    @test IteratorInterfaceExtensions.isiterable(Bag.records) == true
    @test TableTraits.isiterabletable(Bag.records) == true

    @test Bag.records == loaded
    @test Bag.records == loaded_from_headerless

    # Save and load from Vector{Bedgraph.Record}.
    save(Bag.tmp_output_path, Bag.records)

    @debug "direct load into Vector{Bedgraph.Record} - commencing"
    @test Bag.records == Vector{Bedgraph.Record}(load(Bag.tmp_output_path))
    @test Bag.records == collect(Bedgraph.Record, load(Bag.tmp_output_path))
    @debug "direct load into Vector{Bedgraph.Record} - complete"

    @test Bag.records == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}

    # Save using pipe.
    Bag.records |> save(Bag.tmp_output_path)
    @test Bag.records == Vector{Bedgraph.Record}(load(Bag.tmp_output_path))
    @test Bag.records == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}

    # Check return of data from save method.
    @test Bag.records == Bag.records |> save(Bag.tmp_output_path)

    # Check convert
    @test Bag.record == convert(Bedgraph.Record, (chrom = "chr1", first=1, last=1, value=0))
    @test Bag.record == convert(Bedgraph.Record, (chrom = "chr1", left=1, right=1, value=0))

    @testset "Integrations" begin
        include("integrations/test-Tables.jl")
        include("integrations/test-QueryOperators.jl")
    end # testset Integrations

    println()
    show(load(Bag.file))
    println()

end
