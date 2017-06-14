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
    { tools : List ToolGroup
    , currentTool : Tool
    , currentDirection : Direction
    , currentToolGroup : ToolGroupType
    }


type alias ToolGroup =
    { tools : List ToolRow
    , type_ : ToolGroupType
    }


type ToolGroupType
    = Logistics
    | Production


type Tool
    = Placeable Entity
    | Clear


type alias ToolRow =
    List Tool


initialModel : Model
initialModel =
    { tools =
        [ logisticsToolGroup, productionToolGroup ]
    , currentTool = clearTool
    , currentDirection = Up
    , currentToolGroup = Logistics
    }


emptyToolGroup : ToolGroup
emptyToolGroup =
    ToolGroup [] Logistics


logisticsToolGroup : ToolGroup
logisticsToolGroup =
    ToolGroup [ chestTools, transportBeltTools ] Logistics


productionToolGroup : ToolGroup
productionToolGroup =
    ToolGroup [ assemblingMachineTools ] Production


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


assemblingMachineTools : ToolRow
assemblingMachineTools =
    buildToolRow [ AssemblingMachine1, AssemblingMachine2, AssemblingMachine3 ]


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
    | SelectTab ToolGroupType


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

        SelectTab type_ ->
            ( { model | currentToolGroup = type_ }, Cmd.none )


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
    let
        toolGroup =
            List.filter (\toolGroup -> toolGroup.type_ == model.currentToolGroup) model.tools
                |> List.head
    in
        div [ id [ Container ] ]
            [ text "ToolBox"
            , selectableToolView model clearTool
            , div [ id [ ToolGroupContainer ] ]
                [ div [ id [ ToolboxStyles.ToolGroup ] ] (List.map (toolGroupTabs model) model.tools)
                , toolGroupView model toolGroup
                ]
            ]


imageForToolGroup : ToolGroup -> String
imageForToolGroup toolGroup =
    case toolGroup.type_ of
        Logistics ->
            "assets/images/item-group/logistics.png"

        Production ->
            "assets/images/item-group/production.png"


toolGroupTabs : Model -> ToolGroup -> Html Msg
toolGroupTabs model toolGroup =
    let
        classes =
            if toolGroup.type_ == model.currentToolGroup then
                class [ ToolGroupItem, SelectedToolGroupItem ]
            else
                class [ ToolGroupItem ]
    in
        div [ classes, onClick (SelectTab toolGroup.type_) ] [ img [ src (imageForToolGroup toolGroup) ] [] ]


toolGroupView : Model -> Maybe ToolGroup -> Html Msg
toolGroupView model toolGroupMaybe =
    case toolGroupMaybe of
        Just toolGroup ->
            div [ id [ ToolboxItems ] ] (List.map (toolRow model) toolGroup.tools)

        Nothing ->
            text "Please select a tool group."


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
