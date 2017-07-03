port module Ports exposing (..)

import Json.Decode exposing (Value)


-- COMMANDS


{-| Get the offset of the grid DOM element.

Calls back to the `receiveExportedBlueprint` port with the actual offset
-}
port getOffsetOfGrid : () -> Cmd msg


{-| Sends a blueprint string to get parsed into objects.

Calls back to the `loadBlueprint` port with the `Value` which represents the JSON which was parsed from the blueprint
-}
port parseBlueprint : String -> Cmd msg


{-| Export a JSON `Value` to be parsed into a Blueprint String.

-}
port exportBlueprint : Value -> Cmd msg



-- SUBSCRIPTIONS


port receiveExportedBlueprint : (String -> msg) -> Sub msg


port receiveOffset : (( Float, Float ) -> msg) -> Sub msg


port loadBlueprint : (Value -> msg) -> Sub msg
