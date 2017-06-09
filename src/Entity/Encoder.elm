module Entity.Encoder exposing (..)

import Json.Encode exposing (..)
import Entity exposing (Entity, EntityName(..), Position, Direction(..))


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


nameToString : EntityName -> String
nameToString entityName =
    case entityName of
        TransportBelt ->
            "transport-belt"

        FastTransportBelt ->
            "fast-transport-belt"

        Other str ->
            str


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
