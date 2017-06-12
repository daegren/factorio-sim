module Entity exposing (..)


type alias Position =
    { x : Float
    , y : Float
    }


zeroPosition : Position
zeroPosition =
    { x = 0.0, y = 0.0 }


type alias Entity =
    { name : EntityName
    , position : Position
    , direction : Direction
    }


toolboxEntity : EntityName -> Entity
toolboxEntity name =
    Entity name zeroPosition Up


type EntityName
    = TransportBelt
    | FastTransportBelt
    | ExpressTransportBelt
    | WoodenChest
    | Other String


type Direction
    = Up
    | Right
    | Down
    | Left


readableName : EntityName -> String
readableName entityName =
    case entityName of
        TransportBelt ->
            "Transport Belt"

        FastTransportBelt ->
            "Fast Transport Belt"

        ExpressTransportBelt ->
            "Express Transport Belt"

        WoodenChest ->
            "Wooden Chest"

        Other str ->
            str
