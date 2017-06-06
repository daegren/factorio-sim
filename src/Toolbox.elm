module Toolbox exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, alt)
import Html.CssHelpers
import ToolboxStyles exposing (Classes(..), Ids(..))
import Html.Events exposing (onClick)
import Keyboard
import Input exposing (mapKeyboardToInput, Input(..))
import Entity exposing (Entity, Direction(..))


-- MODEL


type alias Model =
    { tools : List Tool
    , currentTool : Tool
    , currentDirection : Direction
    }


type alias Tool =
    { name : String
    , toolType : ToolType
    }


type ToolType
    = Clear
    | TransportBelt


initialModel : Model
initialModel =
    { tools =
        [ clearTool, transportBeltTool ]
    , currentTool = clearTool
    , currentDirection = Up
    }


clearTool : Tool
clearTool =
    Tool "Clear Tool" Clear


transportBeltTool : Tool
transportBeltTool =
    Tool "Transport Belt" TransportBelt


imageForTool : Direction -> Tool -> String
imageForTool direction tool =
    case tool.toolType of
        Clear ->
            "/assets/images/cancel.png"

        TransportBelt ->
            case direction of
                Up ->
                    "/assets/images/belt/belt-up.png"

                Right ->
                    "/assets/images/belt/belt-right.png"

                Down ->
                    "/assets/images/belt/belt-down.png"

                Left ->
                    "/assets/images/belt/belt-left.png"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.presses KeyPressed



-- UPDATE


type Msg
    = SelectTool Tool
    | KeyPressed Keyboard.KeyCode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTool tool ->
            ( { model | currentTool = tool }, Cmd.none )

        KeyPressed keyCode ->
            case mapKeyboardToInput keyCode of
                Just input ->
                    case input of
                        Rotate ->
                            ( { model | currentDirection = rotateDirection model.currentDirection }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )


rotateDirection : Direction -> Direction
rotateDirection orientation =
    case orientation of
        Up ->
            Right

        Right ->
            Down

        Down ->
            Left

        Left ->
            Up



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "toolbox"



-- VIEW


view : Model -> Html Msg
view model =
    div [ id [ Container ] ]
        [ text "ToolBox"
        , div []
            [ text "Current Tool:"
            , div [ class [ CurrentTool ] ] [ currentToolView model model.currentTool ]
            ]
        , div []
            [ text "Available Tools:"
            , div [ id [ ToolboxStyles.Toolbox ] ] (List.map (selectableToolView model) model.tools)
            ]
        ]


currentToolView : Model -> Tool -> Html msg
currentToolView model tool =
    toolView model tool


selectableToolView : Model -> Tool -> Html Msg
selectableToolView model tool =
    div [ class [ ToolboxStyles.Tool ], onClick (SelectTool tool) ]
        [ text tool.name
        , toolView model tool
        ]


toolView : Model -> Tool -> Html msg
toolView model tool =
    img [ src (imageForTool model.currentDirection tool), alt tool.name ] []
