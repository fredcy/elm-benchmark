module Benchmark.Program exposing (Program, program)

{-| Provide a driver program that runs a list of benchmark suites and reports
the results.

This is an example of the Benchmark API and can be used as a default benchmark
driver.

@docs program
-}

import Html exposing (Html)
import Html.Attributes as HA
import Benchmark
import Task
import Numeral


type alias Model =
    { results : List Benchmark.Result
    , done : Bool
    , platform : Maybe String
    , errors : List Benchmark.ErrorInfo
    }


type alias Program =
    Platform.Program Never Model Msg


type Msg
    = Started ()
    | Event Benchmark.Event


{-| Create driver program from list of suites.
-}
program : List Benchmark.Suite -> Program
program suites =
    Html.program
        { init = init suites
        , update = update
        , view = view
        , subscriptions = always (Benchmark.events Event)
        }


init : List Benchmark.Suite -> ( Model, Cmd Msg )
init suites =
    ( Model [] False Nothing []
    , Task.perform Started
        (Benchmark.runTask suites)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Event event ->
            case event of
                Benchmark.Start { platform } ->
                    { model | platform = Just platform } ! []

                Benchmark.Cycle result ->
                    { model | results = model.results ++ [ result ] } ! []

                Benchmark.Complete result ->
                    model ! []

                Benchmark.Finished ->
                    { model | done = True } ! []

                Benchmark.BenchError error ->
                    { model | errors = model.errors ++ [ error ] } ! []

        _ ->
            model ! []


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Benchmark results" ]
        , viewPlatform model.platform
        , viewResults model
        , viewErrors model.errors
        , viewStatus model
        ]


viewPlatform platformMaybe =
    case platformMaybe of
        Just platform ->
            Html.div []
                [ Html.h2 [] [ Html.text "Platform" ]
                , Html.p [] [ Html.text platform ]
                ]

        Nothing ->
            Html.text ""


viewStatus : Model -> Html Msg
viewStatus model =
    Html.p []
        [ Html.text
            (if model.done then
                "Done"
             else
                "running ..."
            )
        ]


viewResults : Model -> Html Msg
viewResults model =
    let
        viewResult e =
            if e.samples == [] then
                -- means the benchmark errored out
                Nothing
            else
                let
                    stats =
                        Benchmark.getStats e.samples

                    meanFreq =
                        -- convert mean-period (seconds) to mean-frequency (ops/sec)
                        1 / stats.mean
                in
                    Just
                        (Html.tr
                            []
                            [ Html.td [] [ Html.text e.suite ]
                            , Html.td [] [ Html.text e.benchmark ]
                            , Html.td [ HA.class "numeric" ] [ Html.text (Numeral.format "0" meanFreq) ]
                            , Html.td [ HA.class "numeric" ] [ Html.text (Numeral.format "0.0" stats.relativeMarginOfError) ]
                            , Html.td [ HA.class "numeric" ] [ Html.text (toString stats.size) ]
                            ]
                        )

        th str =
            Html.th [] [ Html.text str ]
    in
        Html.table []
            [ Html.thead []
                (List.map th [ "suite", "benchmark", "ops/sec", "error%", "samples" ])
            , Html.tbody []
                (List.filterMap viewResult model.results)
            ]


viewErrors : List Benchmark.ErrorInfo -> Html Msg
viewErrors errors =
    if errors == [] then
        Html.text ""
    else
        Html.div []
            [ Html.h2 [] [ Html.text "Errors" ]
            , Html.ul [] (List.map viewError errors)
            ]


viewError : Benchmark.ErrorInfo -> Html Msg
viewError error =
    Html.li [] [ Html.text (toString error) ]
