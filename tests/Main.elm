port module Main exposing (..)

import GridTests
import EntityTests
import BlueprintTests
import Test
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit (Test.concat [ GridTests.all, EntityTests.all, BlueprintTests.all ])


port emit : ( String, Value ) -> Cmd msg
