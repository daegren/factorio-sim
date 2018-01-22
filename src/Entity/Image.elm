module Entity.Image exposing (icon, image, sizeFor)

{-| Mapping for entities to their respective images
-}

import Entity exposing (Direction(..), Entity, EntityName(..))


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
            entityPath ++ Entity.entityID entity.name
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


icon : EntityName -> String
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

        AssemblingMachine1 ->
            ( 108, 114 )

        AssemblingMachine2 ->
            ( 108, 110 )

        AssemblingMachine3 ->
            ( 108, 119 )

        TransportBelt ->
            ( 40, 40 )

        FastTransportBelt ->
            ( 40, 40 )

        ExpressTransportBelt ->
            ( 40, 40 )

        Other _ ->
            ( 32, 32 )
