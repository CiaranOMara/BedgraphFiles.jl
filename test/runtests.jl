using FileIO, BedgraphFiles
using Bedgraph

using IteratorInterfaceExtensions
using TableTraits

using DataFrames

using Test
using Logging

# old_logger = global_logger(ConsoleLogger(stdout, Logging.Debug))

module Bag
const chroms = ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
const firsts = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
const lasts = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
const values = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

const file = joinpath(@__DIR__, "data.bedgraph")
const file_headerless = joinpath(@__DIR__, "data-headerless.bedgraph")
end # module Bag

@testset "BedgraphFiles" begin

@test isfile(Bag.file)
@test isfile(Bag.file_headerless)

tmp_output_path = tempname() * ".bedgraph"

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

records = convert(Vector{Bedgraph.Record}, Bag.chroms, Bag.firsts, Bag.lasts, Bag.values)
@test IteratorInterfaceExtensions.isiterable(records) == true
@test TableTraits.isiterabletable(records) == true

@test records == loaded
@test records == loaded_from_headerless

# Save and load from Vector{Bedgraph.Record}.
save(tmp_output_path, records)

@debug "direct load into Vector{Bedgraph.Record} - commencing"
@test records == Vector{Bedgraph.Record}(load(tmp_output_path))
@debug "direct load into Vector{Bedgraph.Record} - complete"

@test records == load(tmp_output_path) |> Vector{Bedgraph.Record}

# Save usign query.
records |> save(tmp_output_path)
@test records == Vector{Bedgraph.Record}(load(tmp_output_path))
@test records == load(tmp_output_path) |> Vector{Bedgraph.Record}

# Check return of data from save method.
@test records == records |> save(tmp_output_path)

@testset "DataFrames" begin
# DataFrame from Vector{Bedgraph.Record}.
df = DataFrame(records)

@test typeof(df) == DataFrame
@test size(df) == (9,4)

@test df[:chrom] == Bag.chroms
@test df[:first] == Bag.firsts
@test df[:last] == Bag.lasts
@test df[:value] == Bag.values

@test DataFrame(records) == records |> DataFrame

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
save(tmp_output_path, df)
@test df == load(tmp_output_path) |> DataFrame

df |> save(tmp_output_path)
@test df == load(tmp_output_path) |> DataFrame

end # test DataFrames


println()
show(load(Bag.file))
println()

end
