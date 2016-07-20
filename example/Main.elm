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
        [ Benchmark.bench "fn1" testfn1 ]


testfn1 =
    \() -> List.map ((+) 1) [1..1000]


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.text <| toString model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
