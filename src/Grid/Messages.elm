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
    | LoadBlueprint
    | BlueprintChanged String
    | SentBlueprint (Result String (List Entity))
    | ExportBlueprint
    | ClearEntities
    | ReceiveExportedBlueprint String
    | ChangeGridSize Int
    | DragStart Mouse.Position
    | DragAt Mouse.Position
    | DragEnd Mouse.Position
