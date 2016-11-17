module Benchmark.Stats exposing (Stats, getStats)

import Array


type alias Stats =
    { size : Int
    , mean : Float
    , variance : Float
    , relativeMarginOfError : Float
    }


{-| Calculate statistics from list of values. This follows what benchmark.js
does in its `evaluate()` function.
-}
getStats : List Float -> Stats
getStats vals =
    let
        ( size, meanVal, variance ) =
            onlineVariance vals

        deviation =
            sqrt variance

        standardError =
            deviation / sqrt (toFloat size)

        degreesOfFreedom =
            size - 1

        criticalValue =
            getCriticalValue degreesOfFreedom

        marginOfError =
            standardError * criticalValue

        relativeMarginOfError =
            marginOfError / meanVal * 100
    in
        { size = size
        , mean = meanVal
        , variance = variance
        , relativeMarginOfError = relativeMarginOfError
        }


{-| Return ( count, mean, variance ) for list of samples.  See
    https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
-}
onlineVariance : List Float -> ( Int, Float, Float )
onlineVariance vals =
    let
        step : Float -> ( Int, Float, Float ) -> ( Int, Float, Float )
        step x ( n, mean, m2 ) =
            let
                n_ =
                    n + 1

                delta =
                    x - mean

                mean_ =
                    mean + delta / (toFloat n_)

                m2_ =
                    m2 + delta * (x - mean_)
            in
                ( n_, mean_, m2_ )

        ( n, mean, m2 ) =
            List.foldl step ( 0, 0.0, 0.0 ) vals
    in
        if n < 2 then
            Debug.crash "n < 2 in onlineVariance"
        else
            ( n, mean, m2 / toFloat (n - 1) )



-- http://www.itl.nist.gov/div898/handbook/eda/section3/eda3672.htm


getCriticalValue : Int -> Float
getCriticalValue degreesOfFreedom =
    Array.get (degreesOfFreedom - 1) tTable975 |> Maybe.withDefault tInf975


tTable975 =
    [ 12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228, 2.201, 2.179, 2.16, 2.145, 2.131, 2.12, 2.11, 2.101, 2.093, 2.086, 2.08, 2.074, 2.069, 2.064, 2.06, 2.056, 2.052, 2.048, 2.045, 2.042, 2.04, 2.037, 2.035, 2.032, 2.03, 2.028, 2.026, 2.024, 2.023, 2.021, 2.02, 2.018, 2.017, 2.015, 2.014, 2.013, 2.012, 2.011, 2.01, 2.009, 2.008, 2.007, 2.006, 2.005, 2.004, 2.003, 2.002, 2.002, 2.001, 2.0, 2.0, 1.999, 1.998, 1.998, 1.997, 1.997, 1.996, 1.995, 1.995, 1.994, 1.994, 1.993, 1.993, 1.993, 1.992, 1.992, 1.991, 1.991, 1.99, 1.99, 1.99, 1.989, 1.989, 1.989, 1.988, 1.988, 1.988, 1.987, 1.987, 1.987, 1.986, 1.986, 1.986, 1.986, 1.985, 1.985, 1.985, 1.984, 1.984, 1.984 ]
        |> Array.fromList


tInf975 =
    1.96
