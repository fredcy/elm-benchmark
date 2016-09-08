module Stats exposing (..)

import Array


mean : List Float -> Float
mean fs =
    List.sum fs / toFloat (List.length fs)


type alias Stats =
    { size : Int
    , mean : Float
    , variance : Float
    , deviation : Float
    , standardError : Float
    , marginOfError : Float
    , relativeMarginOfError : Float
    }


getStats : List Float -> Stats
getStats vals =
    let
        size =
            List.length vals

        meanVal =
            mean vals

        variance =
            (List.map (\v -> (v - meanVal) ^ 2) vals |> List.sum) / toFloat (size - 1)

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
        , deviation = deviation
        , standardError = standardError
        , marginOfError = marginOfError
        , relativeMarginOfError = relativeMarginOfError
        }



-- http://www.itl.nist.gov/div898/handbook/eda/section3/eda3672.htm


getCriticalValue : Int -> Float
getCriticalValue degreesOfFreedom =
    Array.get (degreesOfFreedom - 1) tTable95 |> Maybe.withDefault tInf95


tInf95 =
    1.645


tTable95 =
    [ 6.314, 2.92, 2.353, 2.132, 2.015, 1.943, 1.895, 1.86, 1.833, 1.812, 1.796, 1.782, 1.771, 1.761, 1.753, 1.746, 1.74, 1.734, 1.729, 1.725, 1.721, 1.717, 1.714, 1.711, 1.708, 1.706, 1.703, 1.701, 1.699, 1.697 ]
        |> Array.fromList
