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
    { tools : List ToolRow
    , currentTool : Tool
    , currentDirection : Direction
    }


type Tool
    = Placeable Entity
    | Clear


type alias ToolRow =
    List Tool


initialModel : Model
initialModel =
    { tools =
        [ [ clearTool ], chestTools, transportBeltTools ]
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


toolForEntity : EntityName -> Tool
toolForEntity entityName =
    Placeable (Entity.toolboxEntity entityName)


chestTools : ToolRow
chestTools =
    buildToolRow [ WoodenChest, IronChest, SteelChest ]


transportBeltTools : ToolRow
transportBeltTools =
    buildToolRow [ TransportBelt, FastTransportBelt, ExpressTransportBelt ]


buildToolRow : List EntityName -> ToolRow
buildToolRow entityNameList =
    List.map (\a -> toolForEntity a) entityNameList



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
        , div [ id [ ToolboxStyles.ToolboxItems ] ] (List.map (toolRow model) model.tools)
        ]


toolRow : Model -> ToolRow -> Html Msg
toolRow model toolRow =
    div [ class [ ToolboxStyles.ToolRow ] ] (List.map (selectableToolView model) toolRow)


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
            let
                classes =
                    if tool == model.currentTool then
                        [ Button, SelectedButton ]
                    else
                        [ Button ]
            in
                div [ class classes ]
                    [ img [ src (Entity.Image.icon entity), alt (Entity.readableName entity.name) ] []
                    ]
