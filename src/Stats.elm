module Stats exposing (Stats, getStats)

import Array


type alias Stats =
    { size : Int
    , mean : Float
    , variance : Float
    , relativeMarginOfError : Float
    }


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


{-| See https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
-}
onlineVariance : List Float -> ( Int, Float, Float )
onlineVariance vals =
    let
        step : Float -> ( Int, Float, Float ) -> ( Int, Float, Float )
        step x ( n, mean, m2 ) =
            let
                n' =
                    n + 1

                delta =
                    x - mean

                mean' =
                    mean + delta / n'

                m2' =
                    m2 + delta * (x - mean')
            in
                ( n', mean', m2' )

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


tTable95 =
    [ 6.314, 2.92, 2.353, 2.132, 2.015, 1.943, 1.895, 1.86, 1.833, 1.812, 1.796, 1.782, 1.771, 1.761, 1.753, 1.746, 1.74, 1.734, 1.729, 1.725, 1.721, 1.717, 1.714, 1.711, 1.708, 1.706, 1.703, 1.701, 1.699, 1.697, 1.696, 1.694, 1.692, 1.691, 1.69, 1.688, 1.687, 1.686, 1.685, 1.684, 1.683, 1.682, 1.681, 1.68, 1.679, 1.679, 1.678, 1.677, 1.677, 1.676, 1.675, 1.675, 1.674, 1.674, 1.673, 1.673, 1.672, 1.672, 1.671, 1.671, 1.67, 1.67, 1.669, 1.669, 1.669, 1.668, 1.668, 1.668, 1.667, 1.667, 1.667, 1.666, 1.666, 1.666, 1.665, 1.665, 1.665, 1.665, 1.664, 1.664, 1.664, 1.664, 1.663, 1.663, 1.663, 1.663, 1.663, 1.662, 1.662, 1.662, 1.662, 1.662, 1.661, 1.661, 1.661, 1.661, 1.661, 1.661, 1.66, 1.66 ]
        |> Array.fromList


tInf95 =
    1.645


tTable975 =
    [ 12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228, 2.201, 2.179, 2.16, 2.145, 2.131, 2.12, 2.11, 2.101, 2.093, 2.086, 2.08, 2.074, 2.069, 2.064, 2.06, 2.056, 2.052, 2.048, 2.045, 2.042, 2.04, 2.037, 2.035, 2.032, 2.03, 2.028, 2.026, 2.024, 2.023, 2.021, 2.02, 2.018, 2.017, 2.015, 2.014, 2.013, 2.012, 2.011, 2.01, 2.009, 2.008, 2.007, 2.006, 2.005, 2.004, 2.003, 2.002, 2.002, 2.001, 2.0, 2.0, 1.999, 1.998, 1.998, 1.997, 1.997, 1.996, 1.995, 1.995, 1.994, 1.994, 1.993, 1.993, 1.993, 1.992, 1.992, 1.991, 1.991, 1.99, 1.99, 1.99, 1.989, 1.989, 1.989, 1.988, 1.988, 1.988, 1.987, 1.987, 1.987, 1.986, 1.986, 1.986, 1.986, 1.985, 1.985, 1.985, 1.984, 1.984, 1.984 ]
        |> Array.fromList


tInf975 =
    1.96
