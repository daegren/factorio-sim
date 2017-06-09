module Toolbox exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, alt)
import Html.CssHelpers
import ToolboxStyles exposing (Classes(..), Ids(..))
import Entity.Image
import Html.Events exposing (onClick)
import Keyboard
import Input exposing (mapKeyboardToInput, Input(..))
import Entity exposing (Entity, EntityName(..), Direction(..))


-- MODEL


type alias Model =
    { tools : List Tool
    , currentTool : Tool
    , currentDirection : Direction
    }


type Tool
    = Placeable Entity
    | Clear


initialModel : Model
initialModel =
    { tools =
        [ clearTool, transportBeltTool, fastTransportBeltTool ]
    , currentTool = clearTool
    , currentDirection = Up
    }


currentToolToEntity : Model -> Entity.Position -> Maybe Entity
currentToolToEntity { currentTool, currentDirection } position =
    case currentTool of
        Clear ->
            Nothing

        Placeable entity ->
            Just { entity | position = position, direction = currentDirection }


clearTool : Tool
clearTool =
    Clear


transportBeltTool : Tool
transportBeltTool =
    Placeable (Entity.toolboxEntity TransportBelt)


fastTransportBeltTool : Tool
fastTransportBeltTool =
    Placeable (Entity.toolboxEntity FastTransportBelt)



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
            , div [ id [ ToolboxStyles.ToolboxItems ] ] (List.map (selectableToolView model) model.tools)
            ]
        ]


currentToolView : Model -> Tool -> Html msg
currentToolView model tool =
    toolView model tool


selectableToolView : Model -> Tool -> Html Msg
selectableToolView model tool =
    div [ class [ ToolboxStyles.Tool ], onClick (SelectTool tool) ]
        [ toolView model tool ]


toolView : Model -> Tool -> Html msg
toolView model tool =
    case tool of
        Clear ->
            div [ class [ Button ] ]
                [ img [ src "assets/images/cancel.png", alt "Clear" ] []
                ]

        Placeable entity ->
            div [ class [ Button ] ]
                [ img [ src (Entity.Image.icon entity), alt (Entity.readableName entity.name) ] []
                ]
