module BedgraphFiles

# using Bedgraph
using TableTraits, IterableTables, DataValues, DataFrames
using FileIO

try add_format(format"Bedgraph", (), [".bedgraph"], [:BedgraphFiles]) end # TODO: Remove once BedgraphFiles is registered with FileIO.

struct BedgraphFile
    filename::String
end

function load(f::FileIO.File{FileIO.format"Bedgraph"})
    return BedgraphFile(f.filename)
end

TableTraits.isiterable(x::BedgraphFile) = true
TableTraits.isiterabletable(x::BedgraphFile) = true

function TableTraits.getiterator(file::BedgraphFile)

    # TODO: read using bedgraph package.
    # df = Bedgraph.read(file.filename, DataFrame)

    data = readdlm(file.filename)

    # Track data format: chrom chromStart chromEnd dataValue
    df = DataFrame(chrom=data[:,1], chromStart=data[:,2], chromEnd=data[:,3], dataValue=data[:,4])

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
        output = [convert(Array,it.df[:chrom]) convert(Array,it.df[:chromStart]) convert(Array,it.df[:chromEnd]) convert(Array,it.df[:dataValue]) ]

        writedlm(f.filename, output)
    end

end

end # module
