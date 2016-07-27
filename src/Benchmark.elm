module Benchmark exposing (..)

import Native.Benchmark
import Task exposing (Task)


type Bench
    = Bench


type Suite
    = Suite


type alias Name =
    String


type SuiteError
    = Failed


type Results
    = String


type Event
    = Start Name
    | Cycle Name
    | Complete Name
    | Error Name Name String


bench : Name -> (() -> a) -> Bench
bench =
    Native.Benchmark.bench


suite : Name -> List Bench -> Suite
suite =
    Native.Benchmark.suite


run : List Suite -> Program x -> Program x
run =
    Native.Benchmark.run


runTask : List Suite -> Task SuiteError Results
runTask =
    Native.Benchmark.runTask
