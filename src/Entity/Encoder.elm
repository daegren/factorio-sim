module Entity.Encoder exposing (..)

import Json.Encode exposing (..)
import Entity exposing (Entity, EntityName(..), Position, Direction(..), entityID)


{-| Encode a `List Entity` into a JSON `Value`
-}
encodeEntities : List Entity -> Value
encodeEntities entities =
    list (List.indexedMap encodeEntity entities)


{-| Encode a single `Entity`. Requires an Int as an ID for the `Entity` for proper output.
-}
encodeEntity : Int -> Entity -> Value
encodeEntity idx entity =
    let
        props =
            [ ( "name", string (entityID entity) )
            , ( "position", encodePosition entity.position )
            , ( "entity_number", int idx )
            ]
    in
        encodeDirection entity.direction props
            |> object


{-| Appends a direction field to an object, if required
-}
encodeDirection : Direction -> List ( String, Value ) -> List ( String, Value )
encodeDirection direction props =
    case directionToInt direction of
        Just dir ->
            ( "direction", int dir ) :: props

        Nothing ->
            props


encodePosition : Position -> Value
encodePosition position =
    object
        [ ( "x", float position.x )
        , ( "y", float position.y )
        ]


directionToInt : Direction -> Maybe Int
directionToInt direction =
    case direction of
        Down ->
            Just 4

        Right ->
            Just 2

        Left ->
            Just 6

        Up ->
            Nothing
