using Query #Note: testing QueryOperators via Query.

@testset "QueryOperators" begin

	# Check piping/continuations through Query.jl.
	load("data.bedgraph") |> @filter(_.chrom == "chr19" && _.first > 49302900 && _.last < 49303800) |> save(Bag.tmp_output_path)
	@test [Bedgraph.Record("chr19", 49303200, 49303500, 0.0)] == load(Bag.tmp_output_path) |> Vector{Bedgraph.Record}

end #testset QueryOperators
