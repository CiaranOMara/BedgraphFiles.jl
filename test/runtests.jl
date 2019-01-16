using FileIO
using TableTraits
using DataFrames
using Test

module Bag
const chroms = ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
const chrom_starts = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
const chrom_ends = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
const data_values = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

const file = joinpath(@__DIR__, "data.bedgraph")
const file_headerless = joinpath(@__DIR__, "data-headerless.bedgraph")
end # Bag

@testset "BedgraphFiles" begin

@test isfile(Bag.file)

# Load tests.
loaded = load(Bag.file)
@test isiterable(loaded) == true

## DataFrame
df = DataFrame(loaded)

@test size(df) == (9,4)

@test df[:chrom] == chroms
@test df[:chromStart] == chrom_starts
@test df[:chromEnd] == chrom_ends
@test df[:dataValue] == data_values

## Query DataFrame
df2 = loaded |> DataFrame
@test size(df2) == (9,4)

@test df2[:chrom] == chroms
@test df2[:chromStart] == chrom_starts
@test df2[:chromEnd] == chrom_ends
@test df2[:dataValue] == data_values

# Load tests.
loaded_from_headerless = load(Bag.file_headerless)
@test isiterable(loaded_from_headerless) == true

## DataFrame from headerless bedGraph file.
df_from_headerless = DataFrame(loaded_from_headerless)

@test size(df_from_headerless) == (9,4)

@test df_from_headerless[:chrom] == chroms
@test df_from_headerless[:chromStart] == chrom_starts
@test df_from_headerless[:chromEnd] == chrom_ends
@test df_from_headerless[:dataValue] == data_values

# Save test.
output_filename = tempname() * ".bedgraph"

df |> save(output_filename)

loaded_df = load(output_filename) |> DataFrame

@test df == loaded_df

end
