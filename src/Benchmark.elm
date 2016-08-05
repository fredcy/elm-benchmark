effect module Benchmark
    where { subscription = MySub }
    exposing
        ( Bench
        , Suite
        , Event(..)
        , CycleData
        , Error(..)
        , bench
        , suite
        , suiteWithOptions
        , runTask
        , events
        , maybeCycle
        , isFinished
        )

import Native.Benchmark
import Process
import Task exposing (Task)


{-| Opaque type for the return from `bench`, representing a single benchmark
(function and name).
-}
type Bench
    = Bench


{-| Opaque type for the turn from `suite`, represent a named list of `Bench`
values.
-}
type Suite
    = Suite


type alias Name =
    String


type Error
    = Failed


type alias CycleData =
    { suite : Name
    , benchmark : Name
    , freq : Float
    , rme : Float
    , samples : Int
    }


type Event
    = Start { suite : Name, platform : String }
    | Cycle CycleData
    | Complete { suite : Name }
    | Finished
    | BenchError { suite : Name, benchmark : Name, message : String }


type alias Options =
    { maxTime : Int
    }


maybeCycle : Event -> Maybe CycleData
maybeCycle event =
    case event of
        Cycle data ->
            Just data

        _ ->
            Nothing


isFinished : Event -> Bool
isFinished event =
    case event of
        Finished ->
            True

        _ ->
            False


defaultOptions : Options
defaultOptions =
    { maxTime = 5 }


{-| Create a `Bench` value from the given benchmark name and function.
-}
bench : Name -> (() -> a) -> Bench
bench =
    Native.Benchmark.bench


suiteWithOptions : Options -> Name -> List Bench -> Suite
suiteWithOptions =
    Native.Benchmark.suite


{-| Create a `Suite` from the name and list of benchmarks.
-}
suite : Name -> List Bench -> Suite
suite =
    suiteWithOptions defaultOptions


run : List Suite -> Program x -> Program x
run =
    Native.Benchmark.run


{-| Create a Task from the Suite.
-}
runTask : List Suite -> Task Error (List Event)
runTask =
    Native.Benchmark.runTask



-- effect manager


watch : (Event -> Task Never ()) -> Task x Never
watch =
    Native.Benchmark.watch


events : (Event -> msg) -> Sub msg
events tagger =
    subscription (Tagger tagger)


type MySub msg
    = Tagger (Event -> msg)


type alias State msg =
    Maybe
        { subs : List (MySub msg)
        , watcher : Process.Id
        }


subMap : (a -> b) -> MySub a -> MySub b
subMap func (Tagger tagger) =
    Tagger (tagger >> func)


init : Task Never (State msg)
init =
    Task.succeed Nothing


onEffects : Platform.Router msg Event -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router subs state =
    let
        _ =
            ( router, subs, state )
    in
        case ( state, subs ) of
            ( Nothing, [] ) ->
                Task.succeed Nothing

            ( Just { watcher }, [] ) ->
                Process.kill watcher `Task.andThen` (\_ -> Task.succeed Nothing)

            ( Nothing, _ ) ->
                Process.spawn (watch (Platform.sendToSelf router))
                    `Task.andThen`
                        \watcher ->
                            Task.succeed (Just { subs = subs, watcher = watcher })

            ( Just { watcher }, _ ) ->
                Task.succeed (Just { subs = subs, watcher = watcher })


onSelfMsg : Platform.Router msg Event -> Event -> State msg -> Task Never (State msg)
onSelfMsg router event state =
    let
        _ =
            ( router, event, state )
    in
        case state of
            Nothing ->
                Task.succeed Nothing

            Just { subs } ->
                let
                    send (Tagger tagger) =
                        Platform.sendToApp router (tagger event)
                in
                    Task.sequence (List.map send subs)
                        `Task.andThen` \_ -> Task.succeed state
