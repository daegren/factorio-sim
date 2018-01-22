module Grid.View exposing (view)

import Collage
import Color
import Css exposing (..)
import Element
import Entity exposing (Entity, Size(..))
import Entity.Image
import Entity.Picker
import Grid
import Grid.Messages exposing (Msg(..))
import Grid.Model exposing (BackgroundCell, Model)
import Html.Styled exposing (Html, div, input, label, text, textarea)
import Html.Styled.Attributes exposing (checked, css, type_, value)
import Html.Styled.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave, onWithOptions)
import Json.Decode as Json
import Mouse
import Point exposing (Point)
import Tool exposing (Tool(..))


-- VIEW HELPERS


mouseOptions : Html.Styled.Events.Options
mouseOptions =
    { stopPropagation = True, preventDefault = True }


onMouseDown : (Mouse.Position -> msg) -> Html.Styled.Attribute msg
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
        [ div
            [ css
                [ flex2 (int 0) (int 0)
                , paddingRight (px 8)
                ]
            , Html.Styled.Attributes.id "Grid"
            , onMouseEnter MouseEntered
            , onMouseLeave MouseLeft
            , onMouseDown DragStart
            ]
            [ Collage.collage gridSize
                gridSize
                [ backgroundGrid context.model
                , entities context.model
                , dragPreview context
                , drawGridLines context.model
                ]
                |> Element.toHtml
                |> Html.Styled.fromUnstyled
            ]
        , gridSizeView context.model
        ]


drawGridLines : Model -> Collage.Form
drawGridLines model =
    let
        stops =
            List.range 0 model.size
                |> List.map (\i -> toFloat (i * model.cellSize))

        fullSize =
            toFloat (model.cellSize * model.size)

        buildLine start end =
            Collage.segment start end
                |> Collage.traced (Collage.solid (Color.rgba 255 255 255 0.25))

        horizLines =
            List.map (\x -> buildLine ( x, 0 ) ( x, fullSize )) stops
                |> Collage.group

        vertLines =
            List.map (\y -> buildLine ( 0, y ) ( fullSize, y )) stops
                |> Collage.group
    in
    if model.debug then
        [ horizLines, vertLines ]
            |> Collage.group
            |> Collage.move ( -fullSize / 2, -fullSize / 2 )
    else
        Collage.group []


gridSizeView : Model -> Html Msg
gridSizeView model =
    div []
        [ text "Change grid size"
        , div []
            [ input [ type_ "button", value "-", onClick (ChangeGridSize -2) ] []
            , input [ type_ "button", value "+", onClick (ChangeGridSize 2) ] []
            ]
        , div []
            [ label []
                [ input [ type_ "checkbox", Html.Styled.Attributes.checked model.debug, onClick ToggleDebug ] []
                , text "Show grid lines"
                ]
            ]
        ]


dragPreview : Context -> Collage.Form
dragPreview context =
    case context.model.drag of
        Just drag ->
            if drag.start == drag.current then
                entityPreview context drag.start
            else
                case context.tools.currentTool of
                    Place ->
                        Grid.calculateLineBetweenPoints drag.start drag.current
                            |> Grid.buildLineBetweenPoints (Entity.sizeFor context.picker.currentEntity)
                            |> List.map (entityPreview context)
                            |> Collage.group

                    Clear ->
                        Grid.calculateLineBetweenPoints drag.start drag.current
                            |> Grid.buildLineBetweenPoints (Entity.Square 1)
                            |> List.map (entityPreview context)
                            |> Collage.group

                    SetRecipe ->
                        Collage.rect 0 0
                            |> Collage.filled Color.black

        Nothing ->
            hoverBlock context


entities : Model -> Collage.Form
entities model =
    List.map (buildEntity model) model.entities
        |> Collage.group


recipeGradient : Color.Gradient
recipeGradient =
    Color.radial ( 0, 0 )
        0
        ( 0, 0 )
        24
        [ ( 0, Color.black )
        , ( 0.75, Color.rgba 0 0 0 0.8 )
        , ( 1, Color.rgba 0 0 0 0 )
        ]


buildEntity : Model -> Entity.Entity -> Collage.Form
buildEntity model entity =
    let
        ( x, y ) =
            Entity.Image.sizeFor entity
    in
    let
        elem =
            Element.image x y (Entity.Image.image entity)
                |> Collage.toForm

        collage =
            case entity.recipe of
                Just name ->
                    let
                        icon =
                            [ Collage.circle 32
                                |> Collage.gradient recipeGradient
                            , Element.image 32 32 (Entity.Image.icon name)
                                |> Collage.toForm
                            ]
                                |> Collage.group
                                |> Collage.move ( 0, 10 )
                    in
                    [ elem, icon ]
                        |> Collage.group

                Nothing ->
                    elem
    in
    collage
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
                    Entity.entity picker.currentEntity tools.currentDirection
                        |> Entity.setPosition (Entity.positionFromPoint point)

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

        SetRecipe ->
            Collage.rect 0 0
                |> Collage.filled Color.black


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
