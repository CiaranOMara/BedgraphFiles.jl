# BedgraphFiles.jl

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/CiaranOMara/BedgraphFiles.jl.svg?branch=master)](https://travis-ci.org/CiaranOMara/BedgraphFiles.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/jny2ep4u3cmly8pj/branch/master?svg=true)](https://ci.appveyor.com/project/CiaranOMara/Bedgraphfiles-jl/branch/master)
[![BedgraphFiles](http://pkg.julialang.org/badges/BedgraphFiles_0.7.svg)](http://pkg.julialang.org/?pkg=BedgraphFiles)
[![codecov.io](http://codecov.io/github/CiaranOMara/BedgraphFiles.jl/coverage.svg?branch=master)](http://codecov.io/github/CiaranOMara/BedgraphFiles.jl?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/CiaranOMara/BedgraphFiles.jl/badge.svg?branch=master)](https://coveralls.io/github/CiaranOMara/BedgraphFiles.jl?branch=master)

## Overview

This package provides load and save support for [Bedgraph files](https://github.com/CiaranOMara/Bedgraph.jl)
under the [FileIO.jl](https://github.com/JuliaIO/FileIO.jl) package.

This package is largely -- if not completely -- inspired by the work of [David Anthoff](https://github.com/davidanthoff).

## Installation
Install BedgraphFiles from the Julia REPL:
```julia
using Pkg
add("BedgraphFiles")
#Pkg.add("BedgraphFiles") for julia prior to v 0.7
```

## Usage

### Loading a Bedgraph file

To load a Bedgraph file into a ``Vector{Bedgraph.Record}``, use the following Julia code:

````julia
using FileIO, BedgraphFiles, Bedgraph

records = Vector{Bedgraph.Record}(load("data.bedgraph"))
````

### Saving a Bedgraph file

> **Note:** saving on top of an existing file will overwrite metadata/header information with a minimal working header.

The following example saves a ``Vector{Bedgraph.Record}`` to a Bedgraph file:
````julia
using FileIO, BedgraphFiles, Bedgraph

records = [Bedgraph.Record("chr", i, i + 99, rand()) for i in 1:100:1000]

save("output.bedgraph", records)
````

### IterableTables
The call to ``load`` returns a ``struct`` that is an [IterableTable.jl](https://github.com/davidanthoff/IterableTables.jl), so it can be passed to any function that can handle iterable tables, i.e. all the sinks in [IterableTable.jl](https://github.com/davidanthoff/IterableTables.jl).

To load a Bedgraph file into a `DataFrame`, use the following Julia code:

```julia
using FileIO, BedgraphFiles, DataFrames

df = DataFrame(load("data.bedgraph"))
```

Here are some examples of materialising a Bedgraph file into data structures that are not a `DataFrame`:

```julia
using FileIO, BedgraphFiles, DataTables, IndexedTables, Gadfly

# Load into a DataTable
dt = DataTable(load("data.bedgraph"))

# Load into an IndexedTable
it = IndexedTable(load("data.bedgraph"))

# Plot directly with Gadfly
plot(load("data.bedgraph"), x=:a, y=:b, Geom.line)
```

The following code saves any iterable table as a Bedgraph file:
```julia
using FileIO, BedgraphFiles

it = getiterator(data)

save("output.bedgraph", it)
```
This will work as long as `it` is any of the types supported as sources in [IterableTables.jl](https://github.com/davidanthoff/IterableTables.jl).


### Using the pipe syntax

Both `load` and `save` also support the pipe syntax. For example, to load a Bedgraph file into a `DataFrame`, one can use the following code:

```julia
using FileIO, BedgraphFiles, DataFrame

df = load("data.bedgraph") |> DataFrame
```

To save an iterable table, one can use the following form:

```julia
using FileIO, BedgraphFiles, DataFrame

df = # Aquire a DataFrame somehow

df |> save("output.bedgraph")
```

The pipe syntax is especially useful when combining it with [Query.jl](https://github.com/davidanthoff/Query.jl) queries, for example one can easily load a Bedgraph file, pipe it into a query, then pipe it to the `save` function to store the results in a new file.
