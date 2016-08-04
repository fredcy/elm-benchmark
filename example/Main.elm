module Main exposing (main)

import Html exposing (Html)
import Html.App
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
    let
        -- Sleep before running the benchmark task so that the subscription can
        -- take effect before the task runs. Yech.
        task =
            Process.sleep 0
                `Task.andThen`
                    \_ ->
                        Benchmark.runTask
                            [ suite1
                            , suite2
                            ]
    in
        ( [], Task.perform Error Started task )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Event event ->
            (model ++ [ event ]) ! []

        _ ->
            model ! []


view : Model -> Html Msg
view model =
    let
        li x =
            Html.li [] [ x ]
    in
        Html.div []
            [ Html.h1 [] [ Html.text "Results" ]
            , Html.h2 [] [ Html.text "Raw events from benchmark.js" ]
            , viewRawEvents model
            , Html.h2 [] [ Html.text "Formatted benchmark results" ]
            , viewTable model
            , viewStatus model
            ]


viewStatus : Model -> Html Msg
viewStatus model =
    Html.p []
        [ if List.any isFinishEvent model then
            Html.text "Done"
          else
            Html.text "running ..."
        ]


isFinishEvent : Benchmark.Event -> Bool
isFinishEvent event =
    case event of
        Benchmark.Finished ->
            True

        _ ->
            False


viewRawEvents : Model -> Html Msg
viewRawEvents model =
    let
        viewRawEvent e =
            Html.li [] [ Html.text (toString e) ]
    in
        Html.ol [] (List.map viewRawEvent model)


viewTable : Model -> Html Msg
viewTable model =
    let
        viewResult e =
            Html.tr []
                [ Html.td [] [ Html.text e.suite ]
                , Html.td [] [ Html.text e.benchmark ]
                , Html.td [] [ Html.text (Numeral.format "0.0" e.freq) ]
                , Html.td [] [ Html.text (Numeral.format "0.00" e.rme) ]
                , Html.td [] [ Html.text (toString e.samples) ]
                ]

        th str =
            Html.th [] [ Html.text str ]
    in
        Html.table []
            [ Html.thead []
                (List.map th [ "suite", "benchmark", "freq", "error%", "samples" ])
            , Html.tbody []
                (List.filterMap isCycleEvent model |> sortEvents |> List.map viewResult)
            ]


isCycleEvent : Benchmark.Event -> Maybe Benchmark.CycleData
isCycleEvent event =
    case event of
        Benchmark.Cycle data ->
            Just data

        _ ->
            Nothing


sortEvents : List Benchmark.CycleData -> List Benchmark.CycleData
sortEvents events =
    let
        derivedKey event =
            event.suite
    in
        List.sortBy derivedKey events


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
    --[1..100000]
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

