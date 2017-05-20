module Toolbox exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, alt)
import Html.CssHelpers
import ToolboxStyles exposing (Classes(..), Ids(..))
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    { tools : List Tool
    , currentTool : ToolSelection
    }


type ToolSelection
    = None
    | Selected Tool


type alias Tool =
    { name : String
    , image : String
    }


initialModel : Model
initialModel =
    { tools =
        generateTransportBeltTools
    , currentTool = None
    }


generateTransportBeltTools : List Tool
generateTransportBeltTools =
    let
        directions =
            [ "up", "right", "down", "left" ]
    in
        List.map (\a -> Tool ("Transport belt " ++ a) ("/assets/images/belt/belt-" ++ a ++ ".png")) directions



-- UPDATE


type Msg
    = SelectTool Tool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTool tool ->
            ( { model | currentTool = Selected tool }, Cmd.none )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "toolbox"



-- VIEW


view : Model -> Html Msg
view model =
    div [ id [ Container ] ]
        [ text "ToolBox"
        , div [] [ currentToolView model.currentTool ]
        , div [] [ text "Available Tools:" ]
        , div [ id [ ToolboxStyles.Toolbox ] ] (List.map selectableToolView model.tools)
        ]


currentToolView : ToolSelection -> Html msg
currentToolView toolSelection =
    case toolSelection of
        None ->
            div [] [ text "No tool selected" ]

        Selected tool ->
            toolView tool


selectableToolView : Tool -> Html Msg
selectableToolView tool =
    div [ class [ ToolboxStyles.Tool ], onClick (SelectTool tool) ] [ toolView tool ]


toolView : Tool -> Html msg
toolView tool =
    img [ src tool.image, alt tool.name ] []
