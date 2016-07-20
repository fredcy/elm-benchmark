module Main exposing (main)

import Html
import Html.App
import Benchmark


type alias Model =
    {}


type Msg
    = NoOp


main =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \() -> Html.text "done"
        }
        |> Benchmark.run [ suite1 ]


suite1 : Benchmark.Suite
suite1 =
    Benchmark.suite "suite1"
        [ Benchmark.bench "fn1" testfn1
        , Benchmark.bench "fn2" testfn2
        ]


testdata : List Int
testdata =
    [1..100000]


testfn1 : () -> List Int
testfn1 =
    \() -> List.map ((+) 1) testdata


testfn2 : () -> List Int
testfn2 =
    \() -> List.map ((*) 7) testdata
