module Entity.Encoder exposing (..)

import Json.Encode exposing (..)
import Entity exposing (Entity, EntityName(..), Position, Direction(..), entityID)


encodeEntity : Int -> Entity -> Value
encodeEntity idx entity =
    let
        props =
            [ ( "name", string (entityID entity) )
            , ( "position", encodePosition entity.position )
            , ( "entity_number", int idx )
            ]
    in
        object <|
            case directionToInt entity.direction of
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
