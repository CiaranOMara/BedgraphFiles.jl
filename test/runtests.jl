using FileIO
using IterableTables
using BedgraphFiles
using DataFrames
using Base.Test

@testset "BedgraphFiles" begin

df = load(joinpath(@__DIR__, "data.bedgraph")) |> DataFrame

@test size(df) == (9,4)

@test df[:chrom] == ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
@test df[:chromStart] == [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
@test df[:chromEnd] == [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
@test df[:dataValue] == [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

output_filename = tempname() * ".bedgraph"

try
    df |> save(output_filename)

    df2 = load(output_filename) |> DataFrame

    @test df == df2
finally
    gc()
    rm(output_filename)
end

end
