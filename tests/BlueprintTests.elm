module BlueprintTests exposing (..)

import Test exposing (..)
import Expect
import Blueprint
import Entity exposing (Entity, Position, EntityName(..))


all : Test
all =
    describe "Blueprint Test Suite"
        [ describe "icons"
            [ test "it creates an icon model from an entity" <|
                \() ->
                    Expect.equalLists [ ( 1, TransportBelt ) ] (Blueprint.icons [ transportBeltEntity { x = 0.0, y = 0.0 } ])
            , test "it sorts by total amount of entities" <|
                \() ->
                    Expect.equalLists [ ( 2, TransportBelt ), ( 1, IronChest ) ] (Blueprint.icons [ transportBeltEntity { x = 1, y = 1 }, transportBeltEntity { x = 1, y = 0 }, ironChestEntity { x = 1, y = -1 } ])
            ]
        ]


buildEntity : EntityName -> Position -> Entity
buildEntity name position =
    Entity.toolboxEntity name
        |> Entity.setPosition position


transportBeltEntity : Position -> Entity
transportBeltEntity =
    buildEntity TransportBelt


ironChestEntity : Position -> Entity
ironChestEntity =
    buildEntity IronChest
