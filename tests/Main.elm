port module Main exposing (..)

import GridTests
import EntityTests
import Test
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit (Test.concat [ GridTests.all, EntityTests.all ])


port emit : ( String, Value ) -> Cmd msg
