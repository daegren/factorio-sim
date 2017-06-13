port module Main exposing (..)

import GridTests
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit GridTests.all


port emit : ( String, Value ) -> Cmd msg
