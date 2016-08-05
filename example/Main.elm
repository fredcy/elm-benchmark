module Main exposing (main)

import Html exposing (Html)
import Html.App
import Html.Attributes as HA
import Benchmark
import Process
import Task
import Numeral


type alias Model =
    List Benchmark.Event


type Msg
    = Started (List Benchmark.Event)
    | Error Benchmark.Error
    | Event Benchmark.Event


main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always (Benchmark.events Event)
        }


init : ( Model, Cmd Msg )
init =
    ( []
    , Task.perform Error
        Started
        (Benchmark.runTask
            [ suite1
            , suite2
            ]
        )
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Event event ->
            (model ++ [ event ]) ! []

        _ ->
            model ! []


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Benchmark results" ]
        , viewTable model
        , viewStatus model
        ]


viewStatus : Model -> Html Msg
viewStatus model =
    Html.p []
        [ if List.any Benchmark.isFinished model then
            Html.text "Done"
          else
            Html.text "running ..."
        ]


viewTable : Model -> Html Msg
viewTable model =
    let
        viewResult e =
            Html.tr []
                [ Html.td [] [ Html.text e.suite ]
                , Html.td [] [ Html.text e.benchmark ]
                , Html.td [ HA.class "numeric" ] [ Html.text (Numeral.format "0" e.freq) ]
                , Html.td [ HA.class "numeric" ] [ Html.text (Numeral.format "0.0" e.rme) ]
                , Html.td [ HA.class "numeric" ] [ Html.text (toString e.samples) ]
                ]

        th str =
            Html.th [] [ Html.text str ]
    in
        Html.table []
            [ Html.thead []
                (List.map th [ "suite", "benchmark", "freq", "error%", "samples" ])
            , Html.tbody []
                (List.filterMap Benchmark.maybeCycle model |> List.map viewResult)
            ]



-- benchmarks and their suites


options =
    { maxTime = 2 }


suite1 : Benchmark.Suite
suite1 =
    Benchmark.suiteWithOptions options
        "suite1"
        [ Benchmark.bench "fn1" testfn1
        , Benchmark.bench "fn2" testfn2
        , Benchmark.bench "fn1 again" testfn1
        ]


suite2 : Benchmark.Suite
suite2 =
    Benchmark.suiteWithOptions options
        "suite2"
        [ Benchmark.bench "fn3" testfn3
        , Benchmark.bench "fn3 again" testfn3
        , Benchmark.bench "fn3 another" testfn3
        ]


testdata : List Int
testdata =
    [1..10000]


testfn1 : () -> List Int
testfn1 =
    \() -> List.map ((+) 1) testdata


testfn2 : () -> List Int
testfn2 =
    \() -> List.map ((*) 7) testdata


testfn3 : () -> List Int
testfn3 =
    \() -> List.map (\i -> i // 42) testdata
