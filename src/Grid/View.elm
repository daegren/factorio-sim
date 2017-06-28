module Grid.View exposing (view)

import Html exposing (Html, div, text, input, textarea)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onWithOptions, onMouseEnter, onMouseLeave, onClick, onInput)
import Html.CssHelpers
import Css
import Mouse
import Json.Decode as Json
import Grid.Styles as GridStyles
import Collage
import Element
import Entity.Picker
import Tool exposing (Tool(..))
import Color
import Grid.Messages exposing (Msg(..))
import Grid.Model exposing (Model, BackgroundCell)
import Grid
import Entity.Image
import Entity exposing (Size(..), Entity)
import Point exposing (Point)


-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "grid"


styles : List Css.Mixin -> Html.Attribute msg
styles =
    Css.asPairs >> Html.Attributes.style



-- VIEW HELPERS


mouseOptions : Html.Events.Options
mouseOptions =
    { stopPropagation = True, preventDefault = True }


onMouseDown : (Mouse.Position -> msg) -> Html.Attribute msg
onMouseDown msg =
    onWithOptions "mousedown" mouseOptions (Json.map msg Mouse.position)


{-| Converts a grid point into an (x, y) coordinate in the collage. This represents the center of the cell.

-}
pointToCollageOffset : Model -> Point -> ( Float, Float )
pointToCollageOffset { cellSize, size } point =
    ( toFloat point.x * toFloat cellSize, toFloat point.y * toFloat cellSize * -1 )


{-| Applies an offset to the image based on the entity size.
-}
addEntityOffset : Model -> Entity -> ( Float, Float ) -> ( Float, Float )
addEntityOffset { cellSize } entity ( x, y ) =
    let
        ( imageSizeX, imageSizeY ) =
            Entity.Image.sizeFor entity

        allowedEntities =
            [ Entity.WoodenChest, Entity.IronChest, Entity.SteelChest ]
    in
        if List.member entity.name allowedEntities then
            case Entity.sizeFor entity.name of
                Square size ->
                    ( x + (toFloat imageSizeX - toFloat cellSize * toFloat size) / 2, y + (toFloat imageSizeY - toFloat cellSize * toFloat size) / 2 )
        else
            ( x, y )



-- VIEW


type alias Context =
    { model : Grid.Model.Model
    , tools : Tool.Model
    , picker : Entity.Picker.Model
    }


view : Context -> Html Msg
view context =
    let
        gridSize =
            context.model.cellSize * context.model.size
    in
        div []
            [ div [ id [ GridStyles.Grid ], onMouseEnter MouseEntered, onMouseLeave MouseLeft, onMouseDown DragStart ]
                [ Collage.collage gridSize
                    gridSize
                    [ backgroundGrid context.model
                    , entities context.model
                    , dragPreview context
                    ]
                    |> Element.toHtml
                ]
            , gridSizeView
            ]


gridSizeView : Html Msg
gridSizeView =
    div []
        [ text "Change grid size"
        , div []
            [ input [ type_ "button", value "-", onClick (ChangeGridSize -2) ] []
            , input [ type_ "button", value "+", onClick (ChangeGridSize 2) ] []
            ]
        ]


dragPreview : Context -> Collage.Form
dragPreview context =
    case context.model.drag of
        Just drag ->
            if drag.start == drag.current then
                entityPreview context drag.start
            else
                Grid.calculateLineBetweenPoints drag.start drag.current
                    |> Grid.buildLineBetweenPoints (Entity.sizeFor context.picker.currentEntity)
                    |> List.map (entityPreview context)
                    |> Collage.group

        Nothing ->
            hoverBlock context


entities : Model -> Collage.Form
entities model =
    List.map (buildEntity model) model.entities
        |> Collage.group


buildEntity : Model -> Entity.Entity -> Collage.Form
buildEntity model entity =
    let
        ( x, y ) =
            Entity.Image.sizeFor entity
    in
        Element.image x y (Entity.Image.image entity)
            |> Collage.toForm
            |> Collage.move
                (pointToCollageOffset model { x = floor entity.position.x, y = floor entity.position.y }
                    |> addEntityOffset model entity
                )


entityPreview : Context -> Point -> Collage.Form
entityPreview { model, tools, picker } point =
    case tools.currentTool of
        Clear ->
            Collage.rect 32 32
                |> Collage.filled (Color.rgba 255 255 0 0.25)
                |> Collage.move (pointToCollageOffset model point)

        Place ->
            let
                dummyEntity =
                    { name = picker.currentEntity, position = Entity.positionFromPoint point, direction = tools.currentDirection }

                ( sizeX, sizeY ) =
                    Entity.Image.sizeFor dummyEntity
            in
                Element.image sizeX sizeY (Entity.Image.image dummyEntity)
                    |> Element.opacity 0.66
                    |> Collage.toForm
                    |> Collage.move
                        (pointToCollageOffset model point
                            |> addEntityOffset model dummyEntity
                        )


hoverBlock : Context -> Collage.Form
hoverBlock context =
    case context.model.currentMouseGridPosition of
        Just point ->
            entityPreview context point

        Nothing ->
            Collage.rect 0 0
                |> Collage.filled Color.black


backgroundGrid : Model -> Collage.Form
backgroundGrid model =
    List.map (\row -> elementRow model.cellSize row) model.cells
        |> Element.flow Element.down
        |> Collage.toForm


elementRow : Int -> List BackgroundCell -> Element.Element
elementRow size cells =
    List.map (\c -> Element.image size size c) cells
        |> Element.flow Element.right
