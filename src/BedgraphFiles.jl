module BedgraphFiles

# using Bedgraph
using IterableTables, DataValues, DataFrames
using FileIO

try add_format(format"Bedgraph", (), [".bedgraph"], [:BedgraphFiles]) end # TODO: Remove once BedgraphFiles is registered with FileIO.

struct BedgraphFile
    filename::String
end

function load(f::FileIO.File{FileIO.format"Bedgraph"})
    return BedgraphFile(f.filename)
end

IterableTables.isiterable(x::BedgraphFile) = true
IterableTables.isiterabletable(x::BedgraphFile) = true

function IterableTables.getiterator(file::BedgraphFile)

    # TODO: read using bedgraph package.
    # df = Bedgraph.read(file.filename, DataFrame)

    data = readdlm(file.filename)

    df = DataFrame(Chromosome=data[:,1], Start=data[:,2], End=data[:,3], Value=data[:,4])

    it = getiterator(df)

    return it
end

function save(f::FileIO.File{FileIO.format"Bedgraph"}, data)
    isiterabletable(data) || error("Can't write this data to a Bedgraph file.")

    it = getiterator(data)

    # TODO: save using bedgraph package.
    # ds = IterableTables.get_datastreams_source(it)
    #
    # try
    #     Bedgraph.write(f.filename, ds)
    # finally
    #     Data.close!(ds)
    # end

    try
        output = [convert(Array,it.df[:Chromosome]) convert(Array,it.df[:Start]) convert(Array,it.df[:End]) convert(Array,it.df[:Value]) ]

        writedlm(f.filename, output)
    end

end

end # module
