module Tool exposing (..)

import Css exposing (..)
import Entity exposing (Direction(..))
import Html.Styled exposing (Html, div, img, styled)
import Html.Styled.Attributes exposing (alt, css, src)
import Html.Styled.Events exposing (onClick)
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


buttonStyles : Style
buttonStyles =
    batch
        [ width (px 36)
        , height (px 36)
        , textAlign center
        , verticalAlign center
        , backgroundImage (url "/assets/images/button-36.png")
        , backgroundPosition2 (px -2) zero
        ]


selectedButtonStyles : Style
selectedButtonStyles =
    batch [ backgroundPosition2 (px -40) zero ]


image : List (Html.Styled.Attribute msg) -> List (Html msg) -> Html msg
image =
    styled img
        [ width (px 30)
        , height (px 30)
        , margin2 (px 4) (px 3)
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [] (List.map (toolView model.currentTool) allTool)


toolView : Tool -> Tool -> Html Msg
toolView currentTool tool =
    let
        classes =
            if currentTool == tool then
                [ buttonStyles, selectedButtonStyles ]
            else
                [ buttonStyles ]
    in
    div [ css classes, onClick (SelectTool tool) ]
        [ image [ src (imageFor tool), alt (altFor tool) ] [] ]



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
