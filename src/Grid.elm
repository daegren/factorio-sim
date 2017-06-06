port module Grid exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src)
import Html.CssHelpers
import Css
import Array exposing (Array)
import GridStyles exposing (Classes(..))
import Entity.Image
import Point exposing (Point, zeroPoint)
import Random exposing (Generator)
import Mouse
import Toolbox exposing (ToolType(..))
import Entity exposing (Entity)


-- MODEL


type alias Model =
    { cells : Cells
    , entities : List Entity
    , cellSize : Int
    , size : Int
    , offset : Point
    }


emptyGrid : Model
emptyGrid =
    Model Array.empty [] 32 20 zeroPoint


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


setEntityOnCellAtPoint : Point -> Maybe Entity -> Cells -> Cells
setEntityOnCellAtPoint point entity cells =
    let
        cell =
            case getCellAtPoint point cells of
                Nothing ->
                    Debug.crash "Invalid grid position"

                Just cell ->
                    { cell | entity = entity }

        row =
            case Array.get point.y cells of
                Nothing ->
                    Debug.crash "Impossible!"

                Just row ->
                    row
    in
        Array.set point.y (Array.set point.x cell row) cells


removeEntityOnCellAtPotint : Point -> Cells -> Cells
removeEntityOnCellAtPotint point cells =
    setEntityOnCellAtPoint point Nothing cells



-- entityFromToolbox : Toolbox.Model -> Point -> Entity
-- entityFromToolbox toolbox point =
--     { position = point, image = Toolbox.imageForTool toolbox.currentOrientation toolbox.currentTool }


type alias Cell =
    { image : String
    , entity : Maybe Entity
    }



-- GENERATORS


getGrassCell : Int -> Cell
getGrassCell num =
    Cell ("/assets/images/grass/" ++ (toString num) ++ ".png") Nothing


generateRandomGrassCell : Generator Cell
generateRandomGrassCell =
    Random.map (\i -> getGrassCell i) (Random.int 0 15)


generateArray : Int -> Generator a -> Generator (Array a)
generateArray size gen =
    Random.map Array.fromList (Random.list size gen)


{-| Generate a grid with random background cells

-}
generateGrid : Int -> Generator Cells
generateGrid size =
    generateArray size (generateArray size generateRandomGrassCell)



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        model =
            emptyGrid
    in
        ( model
        , Cmd.batch
            [ Random.generate RandomGrid (generateGrid model.size)
            , getOffsetOfGrid ()
            ]
        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveOffset GridOffset
        , Mouse.clicks MouseClicked
        ]



-- UPDATE


type Msg
    = RandomGrid Cells
    | GridOffset ( Int, Int )
    | MouseClicked Mouse.Position


update : Msg -> Toolbox.Model -> Model -> ( Model, Cmd Msg )
update msg toolbox model =
    case msg of
        RandomGrid grid ->
            ( { model | cells = grid }, Cmd.none )

        GridOffset ( x, y ) ->
            let
                point =
                    Point x y
            in
                ( { model | offset = point }, Cmd.none )

        MouseClicked position ->
            case positionToGridPoint model position of
                Just point ->
                    let
                        entity =
                            Entity Entity.TransportBelt { x = toFloat point.x, y = toFloat point.y } Entity.Up

                        cells =
                            case toolbox.currentTool.toolType of
                                TransportBelt ->
                                    setEntityOnCellAtPoint point (Just entity) model.cells

                                Clear ->
                                    removeEntityOnCellAtPotint point model.cells
                    in
                        ( { model | cells = cells }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )


{-| Converts a mouse position to it's respective grid position.

Returns `Nothing` if Mouse is outside of the grid bounds.
-}
positionToGridPoint : Model -> Mouse.Position -> Maybe Point
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


view : Model -> Html msg
view grid =
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
    let
        imageSource =
            Entity.Image.image entity
    in
        img [ src imageSource ] []
