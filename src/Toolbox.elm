module Toolbox exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, alt)
import Html.CssHelpers
import ToolboxStyles exposing (Classes(..), Ids(..))
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    { tools : List ToolGroup
    , currentTool : Tool
    }


type alias Tool =
    { name : String
    , image : String
    , toolType : ToolType
    }


type ToolType
    = Clear
    | Place


type alias ToolGroup =
    { name : String
    , tools : List Tool
    }


initialModel : Model
initialModel =
    { tools =
        [ clearGroup, transportBeltGroup ]
    , currentTool = clearTool
    }


clearGroup : ToolGroup
clearGroup =
    { name = "Clear"
    , tools = [ clearTool ]
    }


clearTool : Tool
clearTool =
    Tool "Clear Tool" "/assets/images/cancel.png" Clear


transportBeltGroup : ToolGroup
transportBeltGroup =
    { name = "Transport Belt"
    , tools = generateTransportBeltTools
    }


generateTransportBeltTools : List Tool
generateTransportBeltTools =
    let
        directions =
            [ "up", "right", "down", "left" ]
    in
        List.map (\a -> Tool ("Transport belt " ++ a) ("/assets/images/belt/belt-" ++ a ++ ".png") Place) directions



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
            , div [ id [ ToolboxStyles.Toolbox ] ] (List.map toolGroupView model.tools)
            ]
        ]


toolGroupView : ToolGroup -> Html Msg
toolGroupView toolGroup =
    div []
        [ text toolGroup.name
        , div [ class [ ToolList ] ] (List.map selectableToolView toolGroup.tools)
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
