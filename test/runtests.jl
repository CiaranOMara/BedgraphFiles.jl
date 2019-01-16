using BedgraphFiles
using IteratorInterfaceExtensions
using TableTraits
using IterableTables
using FileIO
using DataValues
using DataFrames
using Test

module Bag
const chroms = ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
const firsts = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
const lasts = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
const values = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

const file = joinpath(@__DIR__, "data.bedgraph")
const file_headerless = joinpath(@__DIR__, "data-headerless.bedgraph")
end # Bag

@testset "BedgraphFiles" begin

@test isfile(Bag.file)

# Load tests.
loaded = load(Bag.file)
@test IteratorInterfaceExtensions.isiterable(loaded) == true
@test TableTraits.isiterabletable(loaded) == true


## DataFrame
df = DataFrame(loaded)

@test size(df) == (9,4)

@test df[:chrom] == Bag.chroms
@test df[:first] == Bag.firsts
@test df[:last] == Bag.lasts
@test df[:value] == Bag.values

## Query DataFrame
df2 = loaded |> DataFrame
@test size(df2) == (9,4)

@test df2[:chrom] == Bag.chroms
@test df2[:first] == Bag.firsts
@test df2[:last] == Bag.lasts
@test df2[:value] == Bag.values

# Load tests.
loaded_from_headerless = load(Bag.file_headerless)
@test isiterable(loaded_from_headerless) == true

## DataFrame from headerless bedGraph file.
df_from_headerless = DataFrame(loaded_from_headerless)

@test size(df_from_headerless) == (9,4)

@test df_from_headerless[:chrom] == Bag.chroms
@test df_from_headerless[:first] == Bag.firsts
@test df_from_headerless[:last] == Bag.lasts
@test df_from_headerless[:value] == Bag.values

# Save test.
output_filename = tempname() * ".bedgraph"

df |> save(output_filename)

loaded_df = load(output_filename) |> DataFrame

@test df == loaded_df

end
