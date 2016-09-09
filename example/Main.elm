module Main exposing (main)

import Benchmark
import Program
import Html.App


main : Program Never
main =
    -- Run over range of sizes that should include some stack-overflow cases.
    Program.program
        [ suiteN 10
        , suiteN 1000
        , suiteN 100000
        , suiteN 1000000
        ]


{-| Set shorter benchmark time to make it complete more quickly. -}
options =
    let
        defaults =
            Benchmark.defaultOptions
    in
        { defaults | maxTime = 2 }


{-| Run the benchmark functions over list of given size.
-}
suiteN size =
    let
        testdata =
            [1..size]

        makeBench name foldfn =
            Benchmark.bench name (\() -> foldfn (\x s -> s + x) 0 testdata)
    in
        Benchmark.suiteWithOptions options
            ("size " ++ toString size)
            [ makeBench "List.foldl" List.foldl
            , makeBench "new foldl" newFoldl
            ]


{-| Naive version of foldl that grows the call stack.
-}
newFoldl : (a -> b -> b) -> b -> List a -> b
newFoldl fn initial vals =
    case vals of
        [] ->
            initial

        first :: rest ->
            fn first (newFoldl fn initial rest)
