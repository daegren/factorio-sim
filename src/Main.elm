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
import Array exposing (Array)


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
    { cells : Cells
    , entities : List Entity
    , cellSize : Int
    , size : Int
    , offset : Point
    }


emptyGrid : Grid
emptyGrid =
    Grid Array.empty [] 32 20 zeroPoint


setOffset : Point -> Grid -> Grid
setOffset point grid =
    { grid | offset = point }


type alias Cells =
    Array (Array Cell)


getCellAtPoint : Point -> Cells -> Maybe Cell
getCellAtPoint point cells =
    case Array.get point.y cells of
        Nothing ->
            Nothing

        Just row ->
            case Array.get point.x row of
                Nothing ->
                    Nothing

                Just cell ->
                    Just cell


setEntityOnCellAtPoint : Point -> Entity -> Cells -> Cells
setEntityOnCellAtPoint point entity cells =
    let
        cell =
            case getCellAtPoint point cells of
                Nothing ->
                    Debug.crash "Invalid grid position"

                Just cell ->
                    { cell | entity = Just entity }

        row =
            case Array.get point.y cells of
                Nothing ->
                    Debug.crash "Impossible!"

                Just row ->
                    row
    in
        Array.set point.y (Array.set point.x cell row) cells


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
    , entity : Maybe Entity
    }


getGrassCell : Int -> Cell
getGrassCell num =
    Cell ("/assets/images/grass/" ++ (toString num) ++ ".png") Nothing


generateRandomGrassCell : Generator Cell
generateRandomGrassCell =
    Random.map (\i -> getGrassCell i) (Random.int 0 15)


generateArray : Int -> Generator a -> Generator (Array a)
generateArray size gen =
    Random.map Array.fromList (Random.list size gen)


generateGrid : Int -> Generator Cells
generateGrid size =
    generateArray size (generateArray size generateRandomGrassCell)



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
        , Mouse.clicks MouseClicked
        ]



-- UPDATE


type Msg
    = RandomGrid Cells
    | GridOffset ( Int, Int )
    | MouseMoved Mouse.Position
    | MouseClicked Mouse.Position
    | ToolboxMsg Toolbox.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomGrid grid ->
            let
                existingGrid =
                    model.grid

                gridModel =
                    { existingGrid | cells = grid }
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

        MouseClicked position ->
            case positionToGridPoint model.grid position of
                Just point ->
                    let
                        entity =
                            Entity point model.toolbox.currentTool.image

                        cells =
                            setEntityOnCellAtPoint point entity model.grid.cells

                        grid =
                            model.grid

                        updatedGrid =
                            { grid | cells = cells }
                    in
                        ( { model | grid = updatedGrid }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

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
    let
        rows =
            Array.toList grid.cells
    in
        div [ id [ GridStyles.Grid ] ] (List.map buildRow rows)


buildRow : Array Cell -> Html msg
buildRow row =
    let
        cells =
            Array.toList row
    in
        div [ class [ Row ] ] (List.map buildCell cells)


buildCell : Cell -> Html msg
buildCell cell =
    let
        entity =
            case cell.entity of
                Just e ->
                    entityView e

                Nothing ->
                    text ""
    in
        div
            [ class [ GridStyles.Cell ]
            , styles [ Css.backgroundImage (Css.url cell.image) ]
            ]
            [ entity ]


entityView : Entity -> Html msg
entityView entity =
    img [ src entity.image ] []
