port module Main exposing (..)

import Html exposing (Html, h1, div, text, img)
import Html.Attributes exposing (src)
import Random exposing (Generator)
import GridStyles exposing (Classes(..), Ids(..))
import SharedStyles exposing (Classes(..))
import Html.CssHelpers
import Mouse
import Toolbox
import Css


-- MODEL


type alias Model =
    { grid : Grid
    , mouseGridPosition : Maybe Point
    , currentMousePosition : Point
    , toolbox : Toolbox.Model
    }


type alias Entity =
    { position : Point
    , image : String
    }
type alias Grid =
    { background : BackgroundGrid
    , entities : List Entity
    , cellSize : Int
    , size : Int
    , offset : Point
    }


emptyGrid : Grid
emptyGrid =
    Grid [] [] 32 20 zeroPoint


setOffset : Point -> Grid -> Grid
setOffset point grid =
    { grid | offset = point }


type alias BackgroundGrid =
    List (List Cell)


{-| Represents a point in a coordinate system

    Point 10 12
-}
type alias Point =
    { x : Int
    , y : Int
    }


zeroPoint : Point
zeroPoint =
    { x = 0, y = 0 }


type alias Cell =
    { image : String
    }


getGrassCell : Int -> Cell
getGrassCell num =
    Cell ("/assets/images/grass/" ++ (toString num) ++ ".png")


generateRandomGrassCell : Generator Cell
generateRandomGrassCell =
    Random.map (\i -> getGrassCell i) (Random.int 0 15)


generateGrid : Int -> Generator BackgroundGrid
generateGrid size =
    Random.list size (Random.list size generateRandomGrassCell)



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model emptyGrid Nothing zeroPoint Toolbox.initialModel
    in
        ( model
        , Cmd.batch
            [ Random.generate RandomGrid (generateGrid model.grid.size)
            , getOffsetOfGrid ()
            ]
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
        [ receiveOffset GridOffset
        , Mouse.moves MouseMoved
        ]



-- UPDATE


type Msg
    = RandomGrid BackgroundGrid
    | GridOffset ( Int, Int )
    | MouseMoved Mouse.Position
    | ToolboxMsg Toolbox.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomGrid grid ->
            let
                existingGrid =
                    model.grid

                gridModel =
                    { existingGrid | background = grid }
            in
                ( { model | grid = gridModel }, Cmd.none )

        GridOffset ( x, y ) ->
            let
                point =
                    Point x y
            in
                ( { model | grid = (setOffset point model.grid) }, Cmd.none )

        MouseMoved position ->
            ( { model
                | currentMousePosition = (Point position.x position.y)
                , mouseGridPosition = positionToGridPoint model.grid position
              }
            , Cmd.none
            )

        ToolboxMsg msg ->
            let
                ( toolboxModel, toolboxCmd ) =
                    Toolbox.update msg model.toolbox
            in
                ( { model | toolbox = toolboxModel }, Cmd.map ToolboxMsg toolboxCmd )


{-| Converts a mouse position to it's respective grid position.

Returns `Nothing` if Mouse is outside of the grid bounds.
-}
positionToGridPoint : Grid -> Mouse.Position -> Maybe Point
positionToGridPoint grid position =
    let
        x =
            floor ((toFloat (position.x - grid.offset.x)) / (toFloat grid.cellSize))

        y =
            floor ((toFloat (position.y - grid.offset.y)) / (toFloat grid.cellSize))

        gridSize =
            grid.size - 1
    in
        if x > gridSize || x < 0 || y > gridSize || y < 0 then
            Nothing
        else
            Just (Point x y)



-- PORTS


port getOffsetOfGrid : () -> Cmd msg


port receiveOffset : (( Int, Int ) -> msg) -> Sub msg



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
        [ gridView model.grid
        , infoView model
        ]


infoView : Model -> Html Msg
infoView model =
    div [ id [ Info ] ]
        [ h1 [] [ text "Factorio Simulator" ]
        , div []
            [ text "Current Mouse Position: "
            , pointView model.currentMousePosition
            ]
        , div []
            [ text "Current Grid Position: "
            , case model.mouseGridPosition of
                Just point ->
                    pointView point

                Nothing ->
                    div [] [ text "Off grid" ]
            ]
        , div []
            [ Html.map ToolboxMsg (Toolbox.view model.toolbox) ]
        ]


pointView : Point -> Html msg
pointView { x, y } =
    let
        pointText =
            "{ " ++ (toString x) ++ ", " ++ (toString y) ++ " }"
    in
        div [] [ text pointText ]


gridView : Grid -> Html msg
gridView grid =
    div [ id [ GridStyles.Grid ] ] (List.map buildRow grid.background)


buildRow : List Cell -> Html msg
buildRow row =
    div [ class [ Row ] ] (List.map buildCell row)


buildCell : Cell -> Html msg
buildCell cell =
    div
        [ class [ GridStyles.Cell ]
        , styles [ Css.backgroundImage (Css.url cell.image) ]
        ]
        []
