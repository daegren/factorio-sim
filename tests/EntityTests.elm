module EntityTests exposing (..)

import Test exposing (..)
import Expect
import Point exposing (Point)
import Entity


all : Test
all =
    describe "Entity Module Test Suite"
        [ describe "Entity math"
            [ describe "getBoundingRect"
                [ test "min and max should be equal for a 1x1 entity" <|
                    \() ->
                        let
                            ( min, max ) =
                                Entity.getBoundingRect transportBeltEntity
                        in
                            Expect.equal min max
                , test "min and max x coordinate should be 3 appart for a 3x3 entity" <|
                    \() ->
                        let
                            ( min, max ) =
                                Entity.getBoundingRect assemblingMachineEntity
                        in
                            -- 2 here because 0 based
                            Expect.equal 2 (max.x - min.x)
                , test "min and max y coordinate should be 3 appart for a 3x3 entity" <|
                    \() ->
                        let
                            ( min, max ) =
                                Entity.getBoundingRect assemblingMachineEntity
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
