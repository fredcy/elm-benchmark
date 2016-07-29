module Main exposing (main)

import Html exposing (Html)
import Html.App
import Benchmark
import Task


type alias Model =
    {}


type Msg
    = Done Benchmark.Results
    | Error Benchmark.Error
    | Event Benchmark.Event


main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (\_ -> Benchmark.events Event)
        }


init : ( Model, Cmd Msg )
init =
    ( {}
    , Task.perform Error Done (Benchmark.runTask [ suite1 ])
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        _ ->
            model ! []


view : Model -> Html Msg
view model =
    Html.text (toString model)


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
