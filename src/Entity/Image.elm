module Entity.Image exposing (image, icon)

{-| Mapping for entities to their respective images
-}

import Entity exposing (Entity, EntityName(..), Direction(..))


basePath : String
basePath =
    "assets/images/"


iconPath : String
iconPath =
    basePath ++ "icons/"


entityImage : Direction -> String -> String
entityImage direction path =
    case direction of
        Up ->
            path ++ "up.png"

        Right ->
            path ++ "right.png"

        Down ->
            path ++ "down.png"

        Left ->
            path ++ "left.png"


image : Entity -> String
image entity =
    case entity.name of
        TransportBelt ->
            let
                path =
                    basePath ++ "belt/"
            in
                entityImage entity.direction path

        FastTransportBelt ->
            let
                path =
                    basePath ++ "fast-belt/"
            in
                entityImage entity.direction path

        ExpressTransportBelt ->
            let
                path =
                    basePath ++ "express-belt/"
            in
                entityImage entity.direction path

        WoodenChest ->
            basePath ++ "wooden-chest.png"

        Other name ->
            basePath ++ name ++ ".png"


icon : Entity -> String
icon entity =
    case entity.name of
        TransportBelt ->
            iconPath ++ "transport-belt.png"

        FastTransportBelt ->
            iconPath ++ "fast-transport-belt.png"

        ExpressTransportBelt ->
            iconPath ++ "express-transport-belt.png"

        WoodenChest ->
            iconPath ++ "wooden-chest.png"

        Other str ->
            iconPath ++ str ++ ".png"
