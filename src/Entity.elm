module Entity exposing (..)

import Point exposing (Point)


type alias Position =
    { x : Float
    , y : Float
    }


zeroPosition : Position
zeroPosition =
    { x = 0.0, y = 0.0 }


type Size
    = Square Int


type alias Entity =
    { name : EntityName
    , position : Position
    , direction : Direction
    }


toolboxEntity : EntityName -> Entity
toolboxEntity name =
    Entity name zeroPosition Up


setPosition : Position -> Entity -> Entity
setPosition position entity =
    { entity | position = position }


type EntityName
    = TransportBelt
    | FastTransportBelt
    | ExpressTransportBelt
    | WoodenChest
    | IronChest
    | SteelChest
    | AssemblingMachine1
    | AssemblingMachine2
    | AssemblingMachine3
    | Other String


type Direction
    = Up
    | Right
    | Down
    | Left


{-| Converts a `Point` to an `Entity.Position`
-}
positionFromPoint : Point -> Position
positionFromPoint point =
    { x = toFloat point.x, y = toFloat point.y }


pointFromPosition : Position -> Point
pointFromPosition position =
    { x = floor position.x, y = floor position.y }


{-| Calculate the bounding box for a given entity. Uses the entities position to determine the bounding box.
-}
getBoundingRect : Entity -> ( Point, Point )
getBoundingRect entity =
    case sizeFor entity of
        Square size ->
            let
                point =
                    pointFromPosition entity.position

                ( min, max ) =
                    ( floor (toFloat size / 2) * -1, floor (toFloat size / 2) )

                ( minX, maxX ) =
                    ( point.x + min, point.x + max )

                ( minY, maxY ) =
                    ( point.y + min, point.y + max )
            in
                ( Point minX minY, Point maxX maxY )


sizeFor : Entity -> Size
sizeFor { name } =
    case name of
        AssemblingMachine1 ->
            Square 3

        AssemblingMachine2 ->
            Square 3

        AssemblingMachine3 ->
            Square 3

        _ ->
            Square 1


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

        IronChest ->
            "Iron Chest"

        SteelChest ->
            "Steel Chest"

        AssemblingMachine1 ->
            "Assembling Machine 1"

        AssemblingMachine2 ->
            "Assembling Machine 2"

        AssemblingMachine3 ->
            "Assembling Machine 3"

        Other str ->
            str


entityID : EntityName -> String
entityID name =
    case name of
        TransportBelt ->
            "transport-belt"

        FastTransportBelt ->
            "fast-transport-belt"

        ExpressTransportBelt ->
            "express-transport-belt"

        WoodenChest ->
            "wooden-chest"

        IronChest ->
            "iron-chest"

        SteelChest ->
            "steel-chest"

        AssemblingMachine1 ->
            "assembling-machine-1"

        AssemblingMachine2 ->
            "assembling-machine-2"

        AssemblingMachine3 ->
            "assembling-machine-3"

        Other str ->
            str
