module Grid exposing (..)

import Collage exposing (collage, move, Form, filled, rect, segment)
import Element exposing (Element)
import Color
import Mouse
import Html exposing (Html)


--------
-- MODEL
--------


type alias Cell =
    { position : { x : Float, y : Float }
    , dimensions : { width : Float, height : Float }
    , isHovered : Bool
    }


type alias Grid =
    { cells : List Cell
    , dimensions : { width : Float, height : Float }
    , windowOffset : { x : Float, y : Float }
    }


emptyGrid : Grid
emptyGrid =
    Grid [] { width = 0, height = 0 } { x = 0, y = 0 }


type alias Model =
    { grid : Grid }


grid : ( Int, Int ) -> ( Float, Float ) -> ( Float, Float ) -> Float -> Grid
grid ( rows, columns ) ( width, height ) ( offsetX, offsetY ) margin =
    if rows <= 0 || columns <= 0 then
        emptyGrid
    else
        let
            viewWidth =
                toFloat columns
                    * (width + margin)

            viewHeight =
                toFloat rows
                    * (height + margin)

            gridIter : List ( Int, List Int )
            gridIter =
                List.map (\x -> ( x, (List.range 1 columns) )) (List.range 1 rows)

            makeCell : ( Int, Int ) -> Cell
            makeCell ( row, col ) =
                let
                    fCol =
                        toFloat col

                    fRow =
                        toFloat row
                in
                    { position =
                        { x = fCol * width + margin * fCol - viewWidth / 2 - width / 2
                        , y = fRow * height + margin * fRow - height / 2 - viewHeight / 2
                        }
                    , dimensions =
                        { width = width, height = height }
                    , isHovered = False
                    }

            makeRow : ( Int, List Int ) -> List Cell
            makeRow ( row, col ) =
                List.map (\c -> makeCell ( row, c )) col

            makeGrid : List ( Int, List Int ) -> List Cell
            makeGrid =
                List.concat << List.map makeRow
        in
            { cells = makeGrid gridIter
            , dimensions = { width = viewWidth, height = viewHeight }
            , windowOffset = { x = offsetX, y = offsetY }
            }


initialModel : ( Int, Int ) -> ( Float, Float ) -> ( Float, Float ) -> Float -> Model
initialModel gridSize cellSize offset margin =
    { grid = grid gridSize cellSize offset margin }



-------
-- VIEW
-------


drawCell : Cell -> Form
drawCell cell =
    let
        cellColor =
            if cell.isHovered then
                Color.yellow
            else
                Color.red
    in
        move ( cell.position.x, cell.position.y ) <|
            filled cellColor <|
                rect cell.dimensions.width cell.dimensions.height


drawGrid : Grid -> List Form
drawGrid grid =
    List.map drawCell grid.cells


view : Model -> Html msg
view model =
    let
        grid =
            model.grid

        width =
            floor grid.dimensions.width

        height =
            floor grid.dimensions.height
    in
        collage width height (drawGrid grid)
            |> Element.toHtml



--------
-- INPUT
--------


type alias Input =
    { mousePosition : ( Int, Int ) }


convertToViewCoordinates : Grid -> ( Int, Int ) -> ( Int, Int )
convertToViewCoordinates grid ( x, y ) =
    let
        xOffset =
            floor (grid.dimensions.width / 2 + grid.windowOffset.x)

        yOffset =
            floor (grid.dimensions.height / 2 + grid.windowOffset.y)
    in
        ( x - xOffset, yOffset - y )



---------
-- UPDATE
---------


type Msg
    = MouseMoves Mouse.Position


stepCell : Input -> Cell -> Cell
stepCell input cell =
    let
        ( mouseX, mouseY ) =
            input.mousePosition
    in
        if
            toFloat mouseX
                > cell.position.x
                - cell.dimensions.width
                / 2
                && toFloat mouseX
                < cell.position.x
                + cell.dimensions.width
                / 2
                && toFloat mouseY
                > cell.position.y
                - cell.dimensions.height
                / 2
                && toFloat mouseY
                < cell.position.y
                + cell.dimensions.height
                / 2
        then
            { cell | isHovered = True }
        else
            { cell | isHovered = False }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseMoves p ->
            let
                grid =
                    model.grid

                input =
                    Input (convertToViewCoordinates grid ( p.x, p.y ))

                cells =
                    List.map (stepCell input) grid.cells
            in
                ( { model | grid = { grid | cells = cells } }, Cmd.none )



----------------
-- SUBSCRIPTIONS
----------------


subscriptions : Model -> Sub Msg
subscriptions _ =
    Mouse.moves MouseMoves
