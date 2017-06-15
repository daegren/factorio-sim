module Input exposing (..)

import Keyboard exposing (KeyCode)
import Char exposing (fromCode)


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
