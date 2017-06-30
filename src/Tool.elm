module Tool exposing (..)

import Html exposing (Html, div, img)
import Html.Attributes exposing (src, alt)
import Html.Events exposing (onClick)
import Css exposing (Stylesheet)
import Css.Namespace exposing (namespace)
import Html.CssHelpers
import Css.Elements
import Entity exposing (Direction(..))
import Input exposing (Input(..))
import Keyboard


-- MODEL


type alias Model =
    { currentTool : Tool
    , currentDirection : Direction
    }


type Tool
    = Place
    | Clear
    | SetRecipe


init : Model
init =
    { currentTool = Place
    , currentDirection = Up
    }


allTool : List Tool
allTool =
    [ Place, Clear, SetRecipe ]



-- UPDATE


type Msg
    = SelectTool Tool
    | KeyPressed Keyboard.KeyCode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTool tool ->
            ( { model | currentTool = tool }, Cmd.none )

        KeyPressed key ->
            case Input.mapKeyboardToInput key of
                Just input ->
                    case input of
                        Rotate ->
                            ( { model | currentDirection = rotateDirection model.currentDirection }, Cmd.none )

                        ClearSelection ->
                            ( { model | currentTool = Clear }, Cmd.none )

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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.presses KeyPressed



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
    div [] (List.map (toolView model.currentTool) allTool)


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

        SetRecipe ->
            "Set Recipe"


imageFor : Tool -> String
imageFor tool =
    case tool of
        Place ->
            "assets/images/icons/transport-belt.png"

        Clear ->
            "assets/images/cancel.png"

        SetRecipe ->
            "assets/images/icons/assembling-machine-1.png"
