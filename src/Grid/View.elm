module Grid.View exposing (view)

import Html exposing (Html, div, text, input, textarea)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onWithOptions, onMouseEnter, onMouseLeave, onClick, onInput)
import Html.CssHelpers
import Css
import Mouse
import Json.Decode as Json
import GridStyles
import Collage
import Element
import Toolbox exposing (Tool(..))
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


mouseOptions : Html.Events.Options
mouseOptions =
    { stopPropagation = True, preventDefault = True }


onMouseDown : (Mouse.Position -> msg) -> Html.Attribute msg
onMouseDown msg =
    onWithOptions "mousedown" mouseOptions (Json.map msg Mouse.position)



-- VIEW HELPERS


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
            case Entity.sizeFor entity of
                Square size ->
                    ( x + (toFloat imageSizeX - toFloat cellSize * toFloat size) / 2, y + (toFloat imageSizeY - toFloat cellSize * toFloat size) / 2 )
        else
            ( x, y )



-- VIEW


view : Model -> Html Msg
view model =
    let
        gridSize =
            model.cellSize * model.size
    in
        div [ id [ GridStyles.GridContainer ] ]
            [ div [ id [ GridStyles.Grid ], onMouseEnter MouseEntered, onMouseLeave MouseLeft, onMouseDown DragStart ]
                [ Collage.collage gridSize
                    gridSize
                    [ backgroundGrid model
                    , entities model
                    , dragPreview model
                    ]
                    |> Element.toHtml
                ]
            , div []
                [ Html.map ToolboxMsg (Toolbox.view model.toolbox)
                , blueprintInput model
                , gridSizeView
                ]
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


blueprintInput : Model -> Html Msg
blueprintInput model =
    div [ id [ GridStyles.BlueprintInput ] ]
        [ textarea [ class [ GridStyles.Input ], onInput BlueprintChanged, value model.blueprintString ] []
        , input [ type_ "button", value "Load Blueprint", onClick LoadBlueprint ] []
        , input [ type_ "button", value "Export Blueprint", onClick ExportBlueprint ] []
        , input [ type_ "button", value "Clear Entities", onClick ClearEntities ] []
        ]


dragPreview : Model -> Collage.Form
dragPreview model =
    case model.drag of
        Just drag ->
            if drag.start == drag.current then
                entityPreview model drag.start
            else
                Grid.calculateLineBetweenPoints drag.start drag.current
                    |> Grid.buildLineBetweenPoints (Toolbox.sizeFor model.toolbox.currentTool)
                    |> List.map (entityPreview model)
                    |> Collage.group

        Nothing ->
            hoverBlock model


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


entityPreview : Model -> Point -> Collage.Form
entityPreview model point =
    case model.toolbox.currentTool of
        Clear ->
            Collage.rect 32 32
                |> Collage.filled (Color.rgba 255 255 0 0.25)
                |> Collage.move (pointToCollageOffset model point)

        Placeable entity ->
            let
                dummyEntity =
                    { entity | direction = model.toolbox.currentDirection }

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


hoverBlock : Model -> Collage.Form
hoverBlock model =
    case model.currentMouseGridPosition of
        Just point ->
            entityPreview model point

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
