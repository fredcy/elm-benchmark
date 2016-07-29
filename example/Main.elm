module Main exposing (main)

import Html exposing (Html)
import Html.App
import Benchmark
import Process
import Task


type alias Model =
    List Benchmark.Event


type Msg
    = Done Benchmark.Results
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
                `Task.andThen` \_ ->
                                Benchmark.runTask [ suite1 ]
    in
        ( [], Task.perform Error Done task )


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
        viewEvent event =
            Html.li [] [ Html.text (toString event) ]
    in
        Html.ol [] (List.map viewEvent model)


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
