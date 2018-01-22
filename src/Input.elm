module Input exposing (..)

import Char exposing (fromCode)
import Keyboard exposing (KeyCode)


type Input
    = Rotate
    | ClearSelection


{-| Maps a keyboard key press to an Input type
-}
mapKeyboardToInput : KeyCode -> Maybe Input
mapKeyboardToInput keyCode =
    case fromCode keyCode of
        'r' ->
            Just Rotate

        'q' ->
            Just ClearSelection

        _ ->
            Nothing
