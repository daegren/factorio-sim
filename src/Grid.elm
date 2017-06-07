port module Grid exposing (..)

import Html exposing (Html, div)
import Html.Attributes
import Html.CssHelpers
import Css
import GridStyles exposing (Classes(..))
import Color
import Entity.Image
import Point exposing (Point, zeroPoint)
import Random exposing (Generator)
import Mouse
import Toolbox exposing (ToolType(..))
import Entity exposing (Entity)
import Collage
import Element


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
    Model [] [] 32 20 zeroPoint


type alias Cells =
    List (List BackgroundCell)


type alias BackgroundCell =
    String


{-| Adds an entity to the list of entities at the given point. Replaces an existing entity at the same point if one already exists.

    addEntity { x = 0, y = 1} entity entities
-}
addEntity : Point -> Maybe Entity -> List Entity -> List Entity
addEntity point entityMaybe entityList =
    case entityMaybe of
        Just entity ->
            entity :: List.foldl (removeEntity point) [] entityList

        Nothing ->
            entityList


{-| Remove an entity from a list of entities. Intended to be used with `List.foldl`

    List.foldl (removeEntity point) entities
-}
removeEntity : Point -> Entity -> List Entity -> List Entity
removeEntity point entity acc =
    if floor entity.position.x /= point.x || floor entity.position.y /= point.y then
        entity :: acc
    else
        acc



-- GENERATORS


getGrassCell : Int -> BackgroundCell
getGrassCell num =
    "/assets/images/grass/" ++ (toString num) ++ ".png"


generateRandomGrassCell : Generator BackgroundCell
generateRandomGrassCell =
    Random.map (\i -> getGrassCell i) (Random.int 0 15)


{-| Generate a grid with random background cells

-}
generateGrid : Int -> Generator Cells
generateGrid size =
    Random.list size (Random.list size generateRandomGrassCell)



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
                            Toolbox.currentToolToEntity toolbox { x = toFloat point.x, y = toFloat point.y }

                        cells =
                            case toolbox.currentTool.toolType of
                                TransportBelt ->
                                    addEntity point entity model.entities

                                Clear ->
                                    List.foldl (removeEntity point) [] model.entities
                    in
                        ( { model | entities = cells }, Cmd.none )

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


{-| Converts a grid point into an {x, y} coordinate in the collage.

-}
pointToCollageOffset : Model -> Point -> ( Float, Float )
pointToCollageOffset { cellSize, size } point =
    let
        halfSize =
            (toFloat size * toFloat cellSize / 2)

        offset =
            (toFloat cellSize / 2)

        x =
            (toFloat point.x * toFloat cellSize + offset - halfSize)

        y =
            (halfSize - toFloat point.y * toFloat cellSize - offset)
    in
        ( x, y )



-- PORTS


port getOffsetOfGrid : () -> Cmd msg


port loadBlueprint : () -> Cmd msg


port receiveOffset : (( Int, Int ) -> msg) -> Sub msg



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "grid"


styles : List Css.Mixin -> Html.Attribute msg
styles =
    Css.asPairs >> Html.Attributes.style



-- VIEW


view : Maybe Point -> Model -> Html msg
view currentGridPosition model =
    let
        gridSize =
            model.cellSize * model.size
    in
        div [ id [ GridStyles.Grid ] ]
            [ Collage.collage gridSize
                gridSize
                [ backgroundGrid model
                    |> Collage.toForm
                , entities model model.entities
                , hoverBlock currentGridPosition model
                ]
                |> Element.toHtml
            ]


entities : Model -> List Entity -> Collage.Form
entities model entityList =
    let
        buildEntity : Entity.Entity -> Collage.Form
        buildEntity entity =
            Element.image 32 32 (Entity.Image.image entity)
                |> Collage.toForm
                |> Collage.move (pointToCollageOffset model { x = floor entity.position.x, y = floor entity.position.y })
    in
        List.map buildEntity entityList
            |> Collage.group


hoverBlock : Maybe Point -> Model -> Collage.Form
hoverBlock maybePoint model =
    case maybePoint of
        Just point ->
            Collage.rect 32 32
                |> Collage.filled (Color.rgba 255 255 0 0.25)
                |> Collage.move (pointToCollageOffset model point)

        Nothing ->
            Collage.rect 0 0
                |> Collage.filled (Color.black)


backgroundGrid : Model -> Element.Element
backgroundGrid model =
    List.map (\row -> elementRow model.cellSize row) model.cells
        |> Element.flow Element.down


elementRow : Int -> List BackgroundCell -> Element.Element
elementRow size cells =
    List.map (\c -> Element.image size size c) cells
        |> Element.flow Element.right
