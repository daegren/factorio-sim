module Main exposing (..)

import Material
import Material.Layout as Layout
import Material.Scheme as Scheme
import Material.Color as Color
import Html exposing (Html, h1, div, text)
import Task
import Window
import Grid


type alias Model =
    { mdl : Material.Model
    , windowSize : Window.Size
    , gridSize : Grid.Size
    }


type Msg
    = Mdl (Material.Msg Msg)
    | WindowResize Window.Size
    | SetWindowWidth Int
    | SetWindowHeight Int


initialModel : Model
initialModel =
    Model Material.model Grid.emptySize Grid.emptySize


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.batch
        [ Task.perform SetWindowHeight Window.height
        , Task.perform SetWindowWidth Window.width
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl subMsg ->
            Material.update Mdl subMsg model

        WindowResize size ->
            let
                gridSize =
                    Grid.Size size.width (size.height - 123)
            in
                ( { model | windowSize = size, gridSize = gridSize }, Cmd.none )

        SetWindowWidth width ->
            let
                windowSize =
                    Grid.setWidth width model.windowSize

                gridSize =
                    Grid.setWidth width model.gridSize
            in
                ( { model | windowSize = windowSize, gridSize = gridSize }, Cmd.none )

        SetWindowHeight height ->
            let
                windowSize =
                    Grid.setHeight height model.windowSize

                gridSize =
                    Grid.setHeight (height - 123) model.gridSize
            in
                ( { model | windowSize = windowSize, gridSize = gridSize }, Cmd.none )


view : Model -> Html Msg
view model =
    Scheme.topWithScheme Color.Green
        Color.Purple
        (Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader ]
            { header = [ h1 [] [ text "Factorio Simulator" ] ]
            , drawer = []
            , tabs = ( [], [] )
            , main = [ Grid.view model.gridSize ]
            }
        )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Window.resizes WindowResize
        , view = view
        }
