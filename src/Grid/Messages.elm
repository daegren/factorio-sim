module Grid.Messages exposing (Msg(..))

import Grid.Model exposing (Cells)
import Mouse
import Entity exposing (Entity)


type Msg
    = RandomGrid Cells
    | GridOffset ( Float, Float )
    | MouseMoved Mouse.Position
    | MouseEntered
    | MouseLeft
    | SentBlueprint (Result String (List Entity))
    | ClearEntities
    | ChangeGridSize Int
    | DragStart Mouse.Position
    | DragAt Mouse.Position
    | DragEnd Mouse.Position
