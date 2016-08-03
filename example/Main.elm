module Main exposing (main)

import Html exposing (Html)
import Html.App
import Benchmark
import Process
import Task


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
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Benchmark.events Event


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


viewEvent : Benchmark.Event -> Html Msg
viewEvent event =
    case event of
        _ ->
            Html.text (toString event)


view : Model -> Html Msg
view model =
    let
        li x =
            Html.li [] [ x ]
    in
        Html.ol [] (List.map (viewEvent >> li) model)


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


testfn2' : () -> List Int
testfn2' =
    let
        fn i =
            if i % 10000 == 0 then
                i |> Debug.log "testfn2'"
            else
                i * 7
    in
        \() -> List.map fn testdata


testfn3 : () -> List Int
testfn3 =
    \() -> List.map (\i -> i // 42) testdata


testfn3' : () -> List Int
testfn3' =
    let
        fn i =
            if i % 10000 == 0 then
                i |> Debug.log "testfn3"
            else
                i // 42
    in
        \() -> List.map fn testdata
