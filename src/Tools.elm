module Tools exposing (..)

import Html exposing (Html, div, img)
import Html.Attributes exposing (src, alt)
import Html.Events exposing (onClick)
import Css exposing (Stylesheet)
import Css.Namespace exposing (namespace)
import Html.CssHelpers
import Css.Elements


-- MODEL


type alias Model =
    { currentTool : Tool }


type Tool
    = Place
    | Clear


init : Model
init =
    { currentTool = Place }


allTools : List Tool
allTools =
    [ Place, Clear ]



-- UPDATE


type Msg
    = SelectTool Tool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTool tool ->
            ( { model | currentTool = tool }, Cmd.none )



-- CSS


type Classes
    = Button
    | SelectedButton


name : String
name =
    "tools"


css : Stylesheet
css =
    (Css.stylesheet << namespace name)
        [ Css.class Button
            [ Css.width (Css.px 36)
            , Css.height (Css.px 36)
            , Css.textAlign Css.center
            , Css.verticalAlign Css.center
            , Css.backgroundImage (Css.url "~assets/images/button-36.png")
            , Css.backgroundPosition2 (Css.px -2) Css.zero
            , Css.children
                [ Css.Elements.img
                    [ Css.width (Css.px 30)
                    , Css.height (Css.px 30)
                    , Css.margin2 (Css.px 4) (Css.px 3)
                    ]
                ]
            ]
        , Css.class SelectedButton
            [ Css.backgroundPosition2 (Css.px -40) Css.zero ]
        ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace name



-- VIEW


view : Model -> Html Msg
view model =
    div [] (List.map (toolView model.currentTool) allTools)


toolView : Tool -> Tool -> Html Msg
toolView currentTool tool =
    let
        classes =
            if currentTool == tool then
                class [ Button, SelectedButton ]
            else
                class [ Button ]
    in
        div [ classes, onClick (SelectTool tool) ]
            [ img [ src (imageFor tool), alt (altFor tool) ] [] ]



-- VIEW HELPERS


altFor : Tool -> String
altFor tool =
    case tool of
        Place ->
            "Place"

        Clear ->
            "Clear"


imageFor : Tool -> String
imageFor tool =
    case tool of
        Place ->
            "assets/images/tools/place.png"

        Clear ->
            "assets/images/cancel.png"
