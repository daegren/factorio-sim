module Grid.Model exposing (..)

import Point exposing (Point, zeroPoint)
import Entity exposing (Entity)


-- MODEL


type alias Model =
    { cells : Cells
    , entities : List Entity
    , cellSize : Int
    , size : Int
    , offset : Point
    , blueprintString : String
    , shouldIgnoreNextMouseClick : Bool
    , mouseInsideGrid : Bool
    , currentMouseGridPosition : Maybe Point
    , drag : Maybe Drag
    }


emptyGrid : Model
emptyGrid =
    Model [] [] 32 15 zeroPoint "" False False Nothing Nothing


type alias Drag =
    { start : Point
    , current : Point
    }


type alias Cells =
    List (List BackgroundCell)


type alias BackgroundCell =
    String
