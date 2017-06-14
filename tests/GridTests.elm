module GridTests exposing (..)

import Test exposing (..)
import Expect
import Grid
import Point exposing (Point)
import Entity


all : Test
all =
    describe "Grid Module Test Suite"
        [ describe "Entity management"
            [ describe "isEntityAtPoint"
                [ test "1x1 entity should return true when at the same point" <|
                    \() ->
                        Expect.true "should be true" (Grid.isEntityAtPoint (Point 0 0) transportBeltEntity)
                , test "1x1 entity should return false when not at the same point" <|
                    \() ->
                        Expect.false "should be false" (Grid.isEntityAtPoint (Point 1 1) transportBeltEntity)
                , test "3x3 entity should return true when point is at the center point" <|
                    \() ->
                        Expect.true "should be true" (Grid.isEntityAtPoint (Point 0 0) assemblingMachineEntity)
                , test "3x3 entity should return true when point is inside of the entity" <|
                    \() ->
                        Expect.true "should be true" (Grid.isEntityAtPoint (Point -1 -1) assemblingMachineEntity)
                , test "3x3 entity should return false when point is outide of the entity" <|
                    \() ->
                        Expect.false "should be false" (Grid.isEntityAtPoint (Point -2 -2) assemblingMachineEntity)
                ]
            , describe "addEntity"
                [ test "adds an entity to an empty list" <|
                    \() ->
                        Expect.equal [ transportBeltEntity ] (Grid.addEntity transportBeltEntity [])
                , test "replaces an entity that already exists" <|
                    \() ->
                        Expect.equal [ transportBeltEntity ] (Grid.addEntity transportBeltEntity [ transportBeltEntity ])
                , test "adds an entity if at a different point" <|
                    \() ->
                        let
                            newEntity =
                                { transportBeltEntity | position = { x = 1, y = 1 } }
                        in
                            Expect.equal [ newEntity, transportBeltEntity ] (Grid.addEntity newEntity [ transportBeltEntity ])
                , test "replaces a larger entity if new entity added inside of larger entity" <|
                    \() ->
                        let
                            newEntity =
                                { transportBeltEntity | position = { x = 1, y = 1 } }
                        in
                            Expect.equal [ newEntity ] (Grid.addEntity newEntity [ assemblingMachineEntity ])
                ]
            , describe "removeEntityAtPoint"
                [ test "removes an entity at a given point" <|
                    \() ->
                        Expect.equal [] (Grid.removeEntityAtPoint (Point 0 0) [ transportBeltEntity ])
                , test "does not remove an entity if not at point" <|
                    \() ->
                        Expect.equal [ transportBeltEntity ] (Grid.removeEntityAtPoint (Point 1 1) [ transportBeltEntity ])
                , test "removes a larger entity if point is inside of the entity" <|
                    \() ->
                        Expect.equal [] (Grid.removeEntityAtPoint (Point -1 -1) [ assemblingMachineEntity ])
                ]
            , describe "getBoundingRectForEntity"
                [ test "min and max should be equal for a 1x1 entity" <|
                    \() ->
                        let
                            ( min, max ) =
                                Grid.getBoundingRectForEntity transportBeltEntity
                        in
                            Expect.equal min max
                , test "min and max x coordinate should be 3 appart for a 3x3 entity" <|
                    \() ->
                        let
                            ( min, max ) =
                                Grid.getBoundingRectForEntity assemblingMachineEntity
                        in
                            -- 2 here because 0 based
                            Expect.equal 2 (max.x - min.x)
                , test "min and max y coordinate should be 3 appart for a 3x3 entity" <|
                    \() ->
                        let
                            ( min, max ) =
                                Grid.getBoundingRectForEntity assemblingMachineEntity
                        in
                            -- 2 here because 0 based
                            Expect.equal 2 (max.y - min.y)
                ]
            ]
        ]


transportBeltEntity : Entity.Entity
transportBeltEntity =
    Entity.toolboxEntity Entity.TransportBelt


assemblingMachineEntity : Entity.Entity
assemblingMachineEntity =
    Entity.toolboxEntity Entity.AssemblingMachine1