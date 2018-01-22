module Grid.Model exposing (..)

import Entity exposing (Entity)
import Point exposing (Point, zeroPoint)


-- MODEL


type alias Model =
    { cells : Cells
    , entities : List Entity
    , cellSize : Int
    , size : Int
    , offset : Point
    , mouseInsideGrid : Bool
    , currentMouseGridPosition : Maybe Point
    , drag : Maybe Drag
    , debug : Bool
    }


emptyGrid : Model
emptyGrid =
    Model [] [] 32 15 zeroPoint False Nothing Nothing False


type alias Drag =
    { start : Point
    , current : Point
    }


type alias Cells =
    List (List BackgroundCell)


type alias BackgroundCell =
    String
