using FileIO
using TableTraits
using DataFrames
using Base.Test

try add_format(format"Bedgraph", (), [".bedgraph"], [:BedgraphFiles]) end # TODO: Remove once files is registered with FileIO.

@testset "BedgraphFiles" begin

const chrom = ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
const chromStart = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
const chromEnd = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
const dataValue = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

file = joinpath(@__DIR__, "data.bedgraph")

@test isfile(file)

# Load tests.
loaded = load(file)
@test isiterable(loaded) == true

## DataFrame
df = DataFrame(loaded)

@test size(df) == (9,4)

@test df[:chrom] == chrom
@test df[:chromStart] == chromStart
@test df[:chromEnd] == chromEnd
@test df[:dataValue] == dataValue

## Query DataFrame
df2 = loaded |> DataFrame
@test size(df2) == (9,4)

@test df2[:chrom] == chrom
@test df2[:chromStart] == chromStart
@test df2[:chromEnd] == chromEnd
@test df2[:dataValue] == dataValue

# Save test.
output_filename = tempname() * ".bedgraph"

try
    df |> save(output_filename)

    loaded_df = load(output_filename) |> DataFrame

    @test df == loaded_df
finally
    gc()
    rm(output_filename)
end

end
