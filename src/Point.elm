module Point exposing (..)

{-| A point in a coordinate system
-}

import Html exposing (Html, div, text)


{-| Represents a point in a coordinate system

    Point 10 12
-}
type alias Point =
    { x : Int
    , y : Int
    }


{-| Convenience builder for a point at `0, 0`

-}
zeroPoint : Point
zeroPoint =
    { x = 0, y = 0 }


view : Point -> Html msg
view { x, y } =
    let
        pointText =
            "{ " ++ (toString x) ++ ", " ++ (toString y) ++ " }"
    in
        div [] [ text pointText ]
