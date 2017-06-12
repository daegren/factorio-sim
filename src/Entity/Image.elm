module Entity.Image exposing (image, icon, sizeFor)

{-| Mapping for entities to their respective images
-}

import Entity exposing (Entity, EntityName(..), Direction(..))


basePath : String
basePath =
    "assets/images/"


iconPath : String
iconPath =
    basePath ++ "icons/"


entityPath : String
entityPath =
    basePath ++ "entity/"


entityImage : Direction -> String -> String
entityImage direction path =
    case direction of
        Up ->
            path ++ "/up.png"

        Right ->
            path ++ "/right.png"

        Down ->
            path ++ "/down.png"

        Left ->
            path ++ "/left.png"


image : Entity -> String
image entity =
    let
        path =
            entityPath ++ Entity.entityID entity
    in
        case entity.name of
            TransportBelt ->
                entityImage entity.direction path

            FastTransportBelt ->
                entityImage entity.direction path

            ExpressTransportBelt ->
                entityImage entity.direction path

            _ ->
                path ++ ".png"


icon : Entity -> String
icon entity =
    let
        id =
            Entity.entityID entity
    in
        iconPath ++ id ++ ".png"


sizeFor : Entity -> ( Int, Int )
sizeFor entity =
    case entity.name of
        WoodenChest ->
            ( 46, 33 )

        IronChest ->
            ( 46, 33 )

        SteelChest ->
            ( 46, 33 )

        _ ->
            ( 32, 32 )
