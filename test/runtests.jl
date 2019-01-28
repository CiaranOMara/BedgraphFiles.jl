using FileIO, BedgraphFiles
using Bedgraph

using IteratorInterfaceExtensions
using TableTraits

using DataFrames
using Query

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
const records = convert(Vector{Bedgraph.Record}, Bag.chroms, Bag.firsts, Bag.lasts, Bag.values)

const file = joinpath(@__DIR__, "data.bedgraph")
const file_headerless = joinpath(@__DIR__, "data-headerless.bedgraph")

const tmp_output_path = tempname() * ".bedgraph"

end # module Bag


using .Bag


@testset "BedgraphFiles" begin

@test isfile(Bag.file)
@test isfile(Bag.file_headerless)

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
@debug "direct load into Vector{Bedgraph.Record} - complete"

@test Bag.records == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}

# Save usign query.
Bag.records |> save(Bag.tmp_output_path)
@test Bag.records == Vector{Bedgraph.Record}(load(Bag.tmp_output_path))
@test Bag.records == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}

# Check return of data from save method.
@test Bag.records == Bag.records |> save(Bag.tmp_output_path)

# Check piping/continuations through Query.jl.
load("data.bedgraph") |> @filter(_.chrom == "chr19" && _.first > 49302900 && _.last < 49303800) |> save(Bag.tmp_output_path)
@test [Bedgraph.Record("chr19", 49303200, 49303500, 0.0)] == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}

@testset "DataFrames" begin
# DataFrame from Vector{Bedgraph.Record}.
df = DataFrame(Bag.records)

@test typeof(df) == DataFrame
@test size(df) == (9,4)

@test df[:chrom] == Bag.chroms
@test df[:first] == Bag.firsts
@test df[:last] == Bag.lasts
@test df[:value] == Bag.values

@test DataFrame(Bag.records) == Bag.records |> DataFrame

# DataFrame from bedGraph file.
df2 = DataFrame(loader)

@test typeof(df2) == DataFrame
@test size(df2) == (9,4)

@test df2[:chrom] == Bag.chroms
@test df2[:first] == Bag.firsts
@test df2[:last] == Bag.lasts
@test df2[:value] == Bag.values

@test DataFrame(loader) == loader |> DataFrame

# DataFrame from headerless bedGraph file.
df3 = DataFrame(loader_from_headerless)
@test typeof(df3) == DataFrame
@test size(df3) == (9,4)

@test df3[:chrom] == Bag.chroms
@test df3[:first] == Bag.firsts
@test df3[:last] == Bag.lasts
@test df3[:value] == Bag.values

@test DataFrame(loader_from_headerless) == loader_from_headerless |> DataFrame

# Save and load from DataFrame.
save(Bag.tmp_output_path, df)
@test df == load(Bag.tmp_output_path) |> DataFrame

df |> save(Bag.tmp_output_path)
@test df == load(Bag.tmp_output_path) |> DataFrame

end # test DataFrames


println()
show(load(Bag.file))
println()

end
