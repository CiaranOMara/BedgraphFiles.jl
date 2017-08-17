module BedgraphFiles

# using Bedgraph
using IterableTables, DataValues, DataFrames
import FileIO

struct BedgraphFile
    filename::String
end

function load(f::FileIO.File{FileIO.format"Bedgraph"})
    return BedgraphFile(f.filename)
end

IterableTables.isiterable(x::BedgraphFile) = true
IterableTables.isiterabletable(x::BedgraphFile) = true

function IterableTables.getiterator(file::BedgraphFile)

    # df = Bedgraph.read(file.filename, DataFrame)

    data = readdlm(file.filename)

    df = DataFrame(Chromosome=data[:,1], Start=data[:,2], End=data[:,3], Value=data[:,4])

    it = getiterator(df)

    return it
end

end # module
