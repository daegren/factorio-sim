module Entity.Image exposing (image)

{-| Mapping for entities to their respective images
-}

import Entity exposing (Entity, EntityName(..), Direction(..))


basePath : String
basePath =
    "/assets/images/"


image : Entity -> String
image entity =
    case entity.name of
        TransportBelt ->
            let
                path =
                    basePath ++ "/belt/"
            in
                case entity.direction of
                    Up ->
                        path ++ "belt-up.png"

                    Right ->
                        path ++ "belt-right.png"

                    Down ->
                        path ++ "belt-down.png"

                    Left ->
                        path ++ "belt-left.png"

        Other name ->
            basePath ++ "/" ++ name ++ ".png"
