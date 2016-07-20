module Benchmark exposing (..)

import Native.Benchmark


type Bench
    = Bench


type Suite
    = Suite


type alias Name =
    String


bench : Name -> (a -> b) -> Bench
bench =
    Native.Benchmark.bench


suite : Name -> List Bench -> Suite
suite =
    Native.Benchmark.suite


run : List Suite -> Program x -> Program x
run =
    Native.Benchmark.run
