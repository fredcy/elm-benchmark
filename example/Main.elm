module Main exposing (main)

import Html exposing (Html)
import Html.App
import Html.Attributes as HA
import Benchmark
import Process
import Task
import Numeral


type alias Model =
    { results : List Benchmark.Result
    , done : Bool
    , platform : Maybe String
    , errors : List Benchmark.ErrorInfo
    }


type Msg
    = Started ()
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
    ( Model [] False Nothing []
    , Task.perform (\_ -> Debug.crash "Benchmark.runTask failed")
        Started
        (Benchmark.runTask
            [ suiteN 10
            , suiteN 1000
            , suiteN 100000
            , suiteN 1000000
            ]
        )
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
                Nothing
            else
                let
                    stats =
                        Benchmark.getStats e.samples

                    meanFreq =
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



-- benchmarks and their suites


options =
    let
        defaults =
            Benchmark.defaultOptions
    in
        { defaults | maxTime = 2 }


suiteN size =
    let
        testdata =
            [1..size]

        benchFn name fn =
            Benchmark.bench name (\() -> fn 0 testdata)
    in
        Benchmark.suiteWithOptions options
            ("size " ++ toString size)
            [ benchFn "List.foldl" (List.foldl (\x s -> s + x))
            , benchFn "new foldl" (newFoldl (\x s -> s + x))
            ]


newFoldl : (a -> b -> b) -> b -> List a -> b
newFoldl fn initial vals =
    case vals of
        [] ->
            initial

        first :: rest ->
            fn first (newFoldl fn initial rest)
