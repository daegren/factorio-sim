module Entity.Decoder exposing (..)

import Json.Decode exposing (..)
import Entity exposing (Position, Entity, EntityName(..), Direction(..))


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

        "fast-transport-belt" ->
            FastTransportBelt

        "express-transport-belt" ->
            ExpressTransportBelt

        "wooden-chest" ->
            WoodenChest

        "iron-chest" ->
            IronChest

        "steel-chest" ->
            SteelChest

        "assembling-machine-1" ->
            AssemblingMachine1

        "assembling-machine-2" ->
            AssemblingMachine2

        "assembling-machine-3" ->
            AssemblingMachine3

        _ ->
            Other name
