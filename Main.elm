module Main exposing (..)

import Material
import Html exposing (Html, h1, div, text)
import Sidebar
import Grid


type alias Model =
    { mdl : Material.Model
    }


type Msg
    = NoOp


initialModel : Model
initialModel =
    Model Material.model


init : ( Model, Cmd msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html msg
view model =
    div []
        [ h1 [] [ text "Factorio Sim" ]
        , Sidebar.view
        , Grid.view
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
