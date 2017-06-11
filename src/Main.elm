module Main exposing (..)

import Html exposing (Html, h1, h2, div, text, img)
import Html.Attributes exposing (src)
import SharedStyles exposing (Classes(..))
import Html.CssHelpers
import Mouse
import Css
import Point exposing (Point, zeroPoint)
import Grid


-- MODEL


type alias Model =
    { grid : Grid.Model
    , mouseGridPosition : Maybe Point
    , currentMousePosition : Point
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        ( gridModel, gridCmd ) =
            Grid.init

        model =
            Model gridModel Nothing zeroPoint
    in
        ( model
        , Cmd.map GridMsg gridCmd
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
    Sub.batch
        [ Sub.map GridMsg (Grid.subscriptions model.grid)
        , Mouse.moves MouseMoved
        ]



-- UPDATE


type Msg
    = MouseMoved Mouse.Position
    | GridMsg Grid.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseMoved position ->
            ( { model
                | currentMousePosition = (Point position.x position.y)
                , mouseGridPosition = Grid.positionToGridPoint model.grid position
              }
            , Cmd.none
            )

        GridMsg msg ->
            let
                ( gridModel, gridCmd ) =
                    Grid.update msg model.grid
            in
                ( { model | grid = gridModel }, Cmd.map GridMsg gridCmd )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "grid"


styles : List Css.Mixin -> Html.Attribute msg
styles =
    Css.asPairs >> Html.Attributes.style



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Blueprint Maker" ]
        , div [ id [ Main ] ]
            [ Html.map GridMsg (Grid.view model.mouseGridPosition model.grid)
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
        , div [] [ text "R to rotate" ]
        ]
