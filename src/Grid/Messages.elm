module Grid.Messages exposing (Msg(..))

import Entity exposing (Entity)
import Grid.Model exposing (Cells)
import Mouse


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
    | ToggleDebug
