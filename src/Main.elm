module Main exposing (..)

import Html exposing (Html, h1, div, text, img)
import Html.Attributes exposing (src)
import GridStyles exposing (Classes(..), Ids(..))
import SharedStyles exposing (Classes(..))
import Html.CssHelpers
import Mouse
import Toolbox exposing (ToolType(..))
import Css
import Point exposing (Point, zeroPoint)
import Grid


-- MODEL


type alias Model =
    { grid : Grid.Model
    , mouseGridPosition : Maybe Point
    , currentMousePosition : Point
    , toolbox : Toolbox.Model
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        ( gridModel, gridCmd ) =
            Grid.init

        model =
            Model gridModel Nothing zeroPoint Toolbox.initialModel
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
        , Sub.map ToolboxMsg (Toolbox.subscriptions model.toolbox)
        , Mouse.moves MouseMoved
        ]



-- UPDATE


type Msg
    = MouseMoved Mouse.Position
    | ToolboxMsg Toolbox.Msg
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

        ToolboxMsg msg ->
            let
                ( toolboxModel, toolboxCmd ) =
                    Toolbox.update msg model.toolbox
            in
                ( { model | toolbox = toolboxModel }, Cmd.map ToolboxMsg toolboxCmd )

        GridMsg msg ->
            let
                ( gridModel, gridCmd ) =
                    Grid.update msg model.toolbox model.grid
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
    div [ id [ Main ] ]
        [ Html.map GridMsg (Grid.view model.mouseGridPosition model.grid)
        , infoView model
        ]


infoView : Model -> Html Msg
infoView model =
    div [ id [ Info ] ]
        [ h1 [] [ text "Factorio Simulator" ]
        , div []
            [ text "Current Mouse Position: "
            , Point.view model.currentMousePosition
            ]
        , div []
            [ text "Current Grid Position: "
            , case model.mouseGridPosition of
                Just point ->
                    Point.view point

                Nothing ->
                    div [] [ text "Off grid" ]
            ]
        , div []
            [ Html.map ToolboxMsg (Toolbox.view model.toolbox) ]
        ]
