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
                        Expect.equalLists [ transportBeltEntity ] (Grid.addEntity transportBeltEntity [])
                , test "replaces an entity that already exists" <|
                    \() ->
                        Expect.equalLists [ transportBeltEntity ] (Grid.addEntity transportBeltEntity [ transportBeltEntity ])
                , test "adds an entity if at a different point" <|
                    \() ->
                        let
                            newEntity =
                                { transportBeltEntity | position = { x = 1, y = 1 } }
                        in
                            Expect.equalLists [ newEntity, transportBeltEntity ] (Grid.addEntity newEntity [ transportBeltEntity ])
                , test "replaces a larger entity if new entity added inside of larger entity" <|
                    \() ->
                        let
                            newEntity =
                                { transportBeltEntity | position = { x = 1, y = 1 } }
                        in
                            Expect.equalLists [ newEntity ] (Grid.addEntity newEntity [ assemblingMachineEntity ])
                , test "replaces entities that already exist inside of larger entity" <|
                    \() ->
                        let
                            exisitingEntity =
                                { transportBeltEntity | position = { x = 1, y = 1 } }
                        in
                            Expect.equalLists [ assemblingMachineEntity ] (Grid.addEntity assemblingMachineEntity [ exisitingEntity ])
                ]
            , describe "removeEntityAtPoint"
                [ test "removes an entity at a given point" <|
                    \() ->
                        Expect.equalLists [] (Grid.removeEntityAtPoint (Point 0 0) [ transportBeltEntity ])
                , test "does not remove an entity if not at point" <|
                    \() ->
                        Expect.equalLists [ transportBeltEntity ] (Grid.removeEntityAtPoint (Point 1 1) [ transportBeltEntity ])
                , test "removes a larger entity if point is inside of the entity" <|
                    \() ->
                        Expect.equalLists [] (Grid.removeEntityAtPoint (Point -1 -1) [ assemblingMachineEntity ])
                ]
            , describe "replaceEntityInsideEntity"
                [ test "larger entity replaces smaller entities that exist inside of its box" <|
                    \() ->
                        let
                            entity =
                                { assemblingMachineEntity | position = { x = 1, y = 1 } }
                        in
                            Expect.equalLists [] (Grid.replaceEntityInsideEntity entity [ transportBeltEntity ])
                , test "smaller entity replaces larger entity if its placed inisde of the larger entity" <|
                    \() ->
                        let
                            entity =
                                { transportBeltEntity | position = { x = 1, y = 1 } }
                        in
                            Expect.equalLists [] (Grid.replaceEntityInsideEntity entity [ assemblingMachineEntity ])
                ]
            , describe "calculate two points that define a straight line between the given points, clamped to the longest axis"
                [ test "x > y" <|
                    \() ->
                        Expect.equal ( Point -1 -1, Point 2 -1 ) (Grid.calculateLineBetweenPoints (Point -1 -1) (Point 2 1))
                , test "y > x" <|
                    \() ->
                        Expect.equal ( Point -1 -1, Point -1 2 ) (Grid.calculateLineBetweenPoints (Point -1 -1) (Point -2 2))
                ]
            ]
        , describe "build a range between two points to define a line"
            [ test "straight line on the x axis" <|
                \() ->
                    Expect.equalLists [ Point -1 0, Point 0 0, Point 1 0 ] (Grid.buildLineBetweenPoints (Entity.Square 1) ( Point -1 0, Point 1 0 ))
            , test "reversed line on the x axis" <|
                \() ->
                    Expect.equalLists [ Point 1 0, Point 0 0, Point -1 0 ] (Grid.buildLineBetweenPoints (Entity.Square 1) ( Point 1 0, Point -1 0 ))
            , test "straight line on the y axis" <|
                \() ->
                    Expect.equalLists [ Point 0 -1, Point 0 0, Point 0 1, Point 0 2 ] (Grid.buildLineBetweenPoints (Entity.Square 1) ( Point 0 -1, Point 0 2 ))
            , test "reversed line on the y axis" <|
                \() ->
                    Expect.equalLists [ Point 0 1, Point 0 0, Point 0 -1 ] (Grid.buildLineBetweenPoints (Entity.Square 1) ( Point 0 1, Point 0 -1 ))
            , test "accounts for entity size" <|
                \() ->
                    Expect.equalLists [ Point 0 -1, Point 0 2 ] (Grid.buildLineBetweenPoints (Entity.Square 3) ( Point 0 -1, Point 0 2 ))
            ]
        ]


transportBeltEntity : Entity.Entity
transportBeltEntity =
    Entity.toolboxEntity Entity.TransportBelt


assemblingMachineEntity : Entity.Entity
assemblingMachineEntity =
    Entity.toolboxEntity Entity.AssemblingMachine1
