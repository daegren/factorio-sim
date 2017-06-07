module Entity exposing (..)

import Json.Decode exposing (..)


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


decodePosition : Decoder Position
decodePosition =
    map2 Position
        (field "x" float)
        (field "y" float)


decodeEntity : Decoder Entity
decodeEntity =
    map3 Entity
        (map entityName (field "name" string))
        (field "position" decodePosition)
        ((field "direction" int)
            |> maybe
            |> map direction
        )


direction : Maybe Int -> Direction
direction int =
    case int of
        Just dir ->
            case dir of
                4 ->
                    Down

                2 ->
                    Right

                6 ->
                    Left

                _ ->
                    Debug.crash "Found wrong direction."

        Nothing ->
            Up


entityName : String -> EntityName
entityName name =
    case name of
        "transport-belt" ->
            TransportBelt

        _ ->
            Other name
