module Blueprint exposing (..)

import Json.Encode exposing (..)
import Entity exposing (Entity, EntityName)
import Entity.Encoder exposing (encodeEntities)


type alias Icon =
    ( Int, EntityName )


encodeBlueprint : List Entity -> Value
encodeBlueprint entities =
    object
        [ ( "blueprint"
          , object
                [ ( "entities", encodeEntities entities )
                , ( "icons", icons entities |> encodeIcons )
                , ( "item", string "blueprint" )
                , ( "version", int 64425689088 )
                ]
          )
        ]


encodeIcons : List Icon -> Value
encodeIcons icons =
    List.take 4 icons
        |> List.indexedMap encodeIcon
        |> list


encodeIcon : Int -> Icon -> Value
encodeIcon idx ( count, name ) =
    object
        [ ( "signal"
          , object
                [ ( "type", string "item" )
                , ( "name", string (Entity.entityIDFromName name) )
                ]
          )
        , ( "index", int (idx + 1) )
        ]


icons : List Entity -> List Icon
icons entities =
    (List.foldl entityToIcon [] entities)
        |> List.sortWith sortIcons


sortIcons : Icon -> Icon -> Order
sortIcons ( a, _ ) ( b, _ ) =
    case compare a b of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT


entityToIcon : Entity -> List Icon -> List Icon
entityToIcon entity icons =
    case getIcon entity icons of
        Just ( count, name ) ->
            List.map
                (\( aCount, aName ) ->
                    if name == aName then
                        ( aCount + 1, aName )
                    else
                        ( aCount, aName )
                )
                icons

        Nothing ->
            ( 1, entity.name ) :: icons


getIcon : Entity -> List Icon -> Maybe Icon
getIcon entity icons =
    List.filter (\( int, name ) -> name == entity.name) icons
        |> List.head
