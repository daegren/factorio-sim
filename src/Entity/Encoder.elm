module Entity.Encoder exposing (..)

import Json.Encode exposing (..)
import Entity exposing (Entity, Position, nameToString, directionToInt)


encodeEntity : Int -> Entity -> Value
encodeEntity idx entity =
    let
        props =
            [ ( "name", string (nameToString entity.name) )
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
