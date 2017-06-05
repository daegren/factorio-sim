module Toolbox exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, alt)
import Html.CssHelpers
import ToolboxStyles exposing (Classes(..), Ids(..))
import Html.Events exposing (onClick)
import Keyboard
import Input exposing (mapKeyboardToInput, Input(..))


-- MODEL


type alias Model =
    { tools : List Tool
    , currentTool : Tool
    , currentOrientation : Orientation
    }


type alias Tool =
    { name : String
    , toolType : ToolType
    }


type ToolType
    = Clear
    | TransportBelt


type Orientation
    = North
    | East
    | South
    | West


initialModel : Model
initialModel =
    { tools =
        [ clearTool, transportBeltTool ]
    , currentTool = clearTool
    , currentOrientation = North
    }


clearTool : Tool
clearTool =
    Tool "Clear Tool" Clear


transportBeltTool : Tool
transportBeltTool =
    Tool "Transport Belt" TransportBelt


imageForTool : Orientation -> Tool -> String
imageForTool orientation tool =
    case tool.toolType of
        Clear ->
            "/assets/images/cancel.png"

        TransportBelt ->
            case orientation of
                North ->
                    "/assets/images/belt/belt-up.png"

                East ->
                    "/assets/images/belt/belt-right.png"

                South ->
                    "/assets/images/belt/belt-down.png"

                West ->
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
                            ( { model | currentOrientation = rotateOrientation model.currentOrientation }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )


rotateOrientation : Orientation -> Orientation
rotateOrientation orientation =
    case orientation of
        North ->
            East

        East ->
            South

        South ->
            West

        West ->
            North



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
    img [ src (imageForTool model.currentOrientation tool), alt tool.name ] []
