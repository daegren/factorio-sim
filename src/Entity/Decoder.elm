module Entity.Decoder exposing (..)

import Json.Decode exposing (..)
import Entity exposing (Position, Entity, entityName, direction)


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
