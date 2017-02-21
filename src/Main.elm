module Main exposing (..)

import Material
import Material.Layout as Layout
import Material.Scheme as Scheme
import Material.Color as Color
import Html exposing (Html, h1, div, text)
import Grid


-- MODEL


type alias Model =
    { mdl : Material.Model
    , gridModel : Grid.Model
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        grid =
            Grid.initialModel ( 20, 20 ) ( 25, 25 ) ( 0, 123 ) (0)
    in
        ( Model Material.model grid
        , Cmd.none
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
    Sub.map GridMsg (Grid.subscriptions model.gridModel)



-- UPDATE


type Msg
    = Mdl (Material.Msg Msg)
    | GridMsg Grid.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl subMsg ->
            Material.update Mdl subMsg model

        GridMsg subMsg ->
            let
                ( gridModel, gridCmd ) =
                    Grid.update subMsg model.gridModel
            in
                ( { model | gridModel = gridModel }, Cmd.map GridMsg gridCmd )



-- VIEW


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
            , main = [ Grid.view model.gridModel ]
            }
        )
