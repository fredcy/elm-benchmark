module Benchmark exposing (..)

import Native.Benchmark
import Task exposing (Task)


{-| Opaque type for the return from `bench`, representing a single benchmark
(function and name).
-}
type Bench
    = Bench


{-| Opaque type for the turn from `suite`, represent a named list of `Bench`
values.
-}
type Suite
    = Suite


type alias Name =
    String


type SuiteError
    = Failed


type Results
    = List Event


type Event
    = Start Name
    | Cycle String
    | Complete Name
    | Error { suite : Name, benchmark : Name, message : String }


{-| Create a `Bench` value from the given benchmark name and function.
-}
bench : Name -> (() -> a) -> Bench
bench =
    Native.Benchmark.bench


{-| Create a `Suite` from the name and list of benchmarks.
-}
suite : Name -> List Bench -> Suite
suite =
    Native.Benchmark.suite


run : List Suite -> Program x -> Program x
run =
    Native.Benchmark.run


{-| Create a Task from the Suite.
-}
runTask : List Suite -> Task SuiteError Results
runTask =
    Native.Benchmark.runTask
