module Entity exposing (..)


type alias Position =
    { x : Float
    , y : Float
    }


type alias Entity =
    { name : EntityName
    , position : Position
    , direction : Direction
    }


type EntityName
    = TransportBelt
    | Other String


type Direction
    = Up
    | Right
    | Down
    | Left
