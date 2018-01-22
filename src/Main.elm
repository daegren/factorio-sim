module Main exposing (..)

import Game
import Html exposing (Html, div, h1, h2, img, text)
import Html.CssHelpers
import SharedStyles exposing (Classes(..))


-- MODEL


type alias Model =
    { game : Game.Model }



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        ( gameModel, gameCmd ) =
            Game.init
    in
    ( Model gameModel
    , Cmd.map GameMsg gameCmd
    )



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map GameMsg (Game.subscriptions model.game)



-- UPDATE


type Msg
    = GameMsg Game.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GameMsg msg ->
            let
                ( gameModel, gameCmd ) =
                    Game.update msg model.game
            in
            ( { model | game = gameModel }, Cmd.map GameMsg gameCmd )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "grid"



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Blueprint Maker" ]
        , div [ id [ Main ] ]
            [ Html.map GameMsg (Game.view model.game)
            , infoView model
            ]
        , div [ id [ Copyright ] ]
            [ text "Images ©Wube Software Inc."
            ]
        ]


infoView : Model -> Html Msg
infoView model =
    div [] [ helpText ]


helpText : Html msg
helpText =
    div []
        [ h2 [] [ text "Help" ]
        , div [] [ text "Click on an item in the toolbox to set it as your current tool" ]
        , div [] [ text "Left click to place an enitity in the grid" ]
        , div [] [ text "Use the clear tool to remove an enitity" ]
        , div [] [ text "Use the recipe tool to set a recipe for assembling machines." ]
        , div [] [ text "q to clear the mouse" ]
        , div [] [ text "r to rotate" ]
        ]
