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
            ]
        ]


transportBeltEntity : Entity.Entity
transportBeltEntity =
    Entity.toolboxEntity Entity.TransportBelt


assemblingMachineEntity : Entity.Entity
assemblingMachineEntity =
    Entity.toolboxEntity Entity.AssemblingMachine1
