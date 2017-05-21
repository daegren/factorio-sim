module Toolbox exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, alt)
import Html.CssHelpers
import ToolboxStyles exposing (Classes(..), Ids(..))
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    { tools : List Tool
    , currentTool : Tool
    }


type alias Tool =
    { name : String
    , image : String
    }


initialModel : Model
initialModel =
    { tools =
        clearTool :: generateTransportBeltTools
    , currentTool = clearTool
    }


clearTool : Tool
clearTool =
    Tool "Clear Tool" "/assets/images/cancel.png"


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
            ( { model | currentTool = tool }, Cmd.none )



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
            , div [ class [ CurrentTool ] ] [ currentToolView model.currentTool ]
            ]
        , div []
            [ text "Available Tools:"
            , div [ id [ ToolboxStyles.Toolbox ] ] (List.map selectableToolView model.tools)
            ]
        ]


currentToolView : Tool -> Html msg
currentToolView tool =
    toolView tool


selectableToolView : Tool -> Html Msg
selectableToolView tool =
    div [ class [ ToolboxStyles.Tool ], onClick (SelectTool tool) ] [ toolView tool ]


toolView : Tool -> Html msg
toolView tool =
    img [ src tool.image, alt tool.name ] []
