port module Grid exposing (..)

import Html exposing (Html, div, input, textarea, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Css
import GridStyles exposing (Classes(..))
import Entity.Encoder
import Json.Encode
import Entity.Decoder
import Json.Decode exposing (Value)
import Color
import Entity.Image
import Point exposing (Point, zeroPoint)
import Random exposing (Generator)
import Mouse
import Toolbox exposing (Tool(..))
import Entity exposing (Entity, Size(..))
import Collage
import Element


-- MODEL


type alias Model =
    { cells : Cells
    , entities : List Entity
    , cellSize : Int
    , size : Int
    , offset : Point
    , blueprintString : String
    , toolbox : Toolbox.Model
    }


emptyGrid : Model
emptyGrid =
    Model [] [] 32 15 zeroPoint "" Toolbox.initialModel


type alias Cells =
    List (List BackgroundCell)


type alias BackgroundCell =
    String


{-| Adds an entity to the list of entities at the given point. Replaces an existing entity at the same point if one already exists.

    addEntity entity entities
-}
addEntity : Entity -> List Entity -> List Entity
addEntity entity entityList =
    entity :: replaceEntityInsideEntity entity entityList


replaceEntityInsideEntity : Entity -> List Entity -> List Entity
replaceEntityInsideEntity entity entityList =
    let
        ( min, max ) =
            Entity.getBoundingRect entity
    in
        List.filter
            (\e ->
                let
                    ( entityMin, entityMax ) =
                        Entity.getBoundingRect e
                in
                    not
                        ((min.x <= entityMax.x && max.x >= entityMin.x)
                            && (min.y <= entityMax.y && max.y >= entityMin.y)
                        )
            )
            entityList


{-| Remove an entity at a given point

-}
removeEntityAtPoint : Point -> List Entity -> List Entity
removeEntityAtPoint point entityList =
    let
        isEntityNotAtPoint point entity =
            not (isEntityAtPoint point entity)
    in
        List.filter (isEntityNotAtPoint point) entityList


isEntityAtPoint : Point -> Entity -> Bool
isEntityAtPoint point entity =
    case Entity.sizeFor entity of
        Square size ->
            let
                ( min, max ) =
                    Entity.getBoundingRect entity
            in
                (min.x <= point.x && point.x <= max.x && min.y <= point.y && point.y <= max.y)



-- GENERATORS


getGrassCell : Int -> BackgroundCell
getGrassCell num =
    "assets/images/grass/" ++ (toString num) ++ ".png"


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
        , loadBlueprint (Json.Decode.decodeValue (Json.Decode.list Entity.Decoder.decodeEntity) >> SentBlueprint)
        , Sub.map ToolboxMsg (Toolbox.subscriptions model.toolbox)
        , receiveExportedBlueprint ReceiveExportedBlueprint
        ]



-- PORTS


port getOffsetOfGrid : () -> Cmd msg


port parseBlueprint : String -> Cmd msg


port exportBlueprint : Value -> Cmd msg


port receiveOffset : (( Float, Float ) -> msg) -> Sub msg


port loadBlueprint : (Value -> msg) -> Sub msg


port receiveExportedBlueprint : (String -> msg) -> Sub msg



-- UPDATE


type Msg
    = RandomGrid Cells
    | GridOffset ( Float, Float )
    | MouseClicked Mouse.Position
    | LoadBlueprint
    | BlueprintChanged String
    | SentBlueprint (Result String (List Entity))
    | ExportBlueprint
    | ClearEntities
    | ReceiveExportedBlueprint String
    | ChangeGridSize Int
    | ToolboxMsg Toolbox.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomGrid grid ->
            ( { model | cells = grid }, Cmd.none )

        GridOffset ( x, y ) ->
            let
                point =
                    Point (floor x) (floor y)
            in
                ( { model | offset = point }, Cmd.none )

        MouseClicked position ->
            case positionToGridPoint model position of
                Just point ->
                    let
                        cells =
                            case model.toolbox.currentTool of
                                Placeable entity ->
                                    let
                                        newEntity =
                                            { entity | position = Entity.positionFromPoint point, direction = model.toolbox.currentDirection }
                                    in
                                        addEntity newEntity model.entities

                                Clear ->
                                    removeEntityAtPoint point model.entities
                    in
                        ( { model | entities = cells }, exportBlueprint (Json.Encode.list (List.indexedMap Entity.Encoder.encodeEntity cells)) )

                Nothing ->
                    ( model, Cmd.none )

        LoadBlueprint ->
            ( model, parseBlueprint model.blueprintString )

        BlueprintChanged str ->
            ( { model | blueprintString = str }, Cmd.none )

        SentBlueprint res ->
            case res of
                Ok entities ->
                    ( { model | entities = entities }, Cmd.none )

                Err err ->
                    let
                        a =
                            Debug.log "SentBlueprint error" err
                    in
                        ( model, Cmd.none )

        ExportBlueprint ->
            ( model, exportBlueprint (Json.Encode.list (List.indexedMap Entity.Encoder.encodeEntity model.entities)) )

        ClearEntities ->
            ( { model | entities = [], blueprintString = "" }, Cmd.none )

        ReceiveExportedBlueprint blueprintString ->
            ( { model | blueprintString = blueprintString }, Cmd.none )

        ChangeGridSize amount ->
            let
                newSize =
                    model.size + amount
            in
                ( { model | size = newSize }, Random.generate RandomGrid (generateGrid newSize) )

        ToolboxMsg msg ->
            let
                ( toolboxModel, toolboxCmd ) =
                    Toolbox.update msg model.toolbox
            in
                ( { model | toolbox = toolboxModel }, Cmd.map ToolboxMsg toolboxCmd )


{-| Converts a mouse position to it's respective grid position.

Returns `Nothing` if Mouse is outside of the grid bounds.
-}
positionToGridPoint : Model -> Mouse.Position -> Maybe Point
positionToGridPoint grid position =
    let
        width =
            grid.size * grid.cellSize

        halfWidth =
            toFloat width / 2

        offset =
            (toFloat grid.cellSize / 2)

        x =
            floor ((toFloat (position.x - grid.offset.x) + offset) / (toFloat grid.cellSize) - halfWidth / toFloat grid.cellSize)

        y =
            floor ((toFloat (position.y - grid.offset.y) + offset) / (toFloat grid.cellSize) - halfWidth / toFloat grid.cellSize)

        gridMax =
            floor (toFloat grid.size / 2)

        gridMin =
            gridMax * -1
    in
        if x > gridMax || x < gridMin || y > gridMax || y < gridMin then
            Nothing
        else
            Just (Point x y)


{-| Converts a grid point into an (x, y) coordinate in the collage. This represents the center of the cell.

-}
pointToCollageOffset : Model -> Point -> ( Float, Float )
pointToCollageOffset { cellSize, size } point =
    ( toFloat point.x * toFloat cellSize, toFloat point.y * toFloat cellSize * -1 )


{-| Applies an offset to the image based on the entity size.
-}
addEntityOffset : Entity -> ( Float, Float ) -> ( Float, Float )
addEntityOffset entity ( x, y ) =
    let
        ( imageSizeX, imageSizeY ) =
            Entity.Image.sizeFor entity
    in
        case Entity.sizeFor entity of
            Square size ->
                ( x + (toFloat imageSizeX - 32 * toFloat size) / 2, y + (toFloat imageSizeY - 32 * toFloat size) / 2 )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "grid"


styles : List Css.Mixin -> Html.Attribute msg
styles =
    Css.asPairs >> Html.Attributes.style



-- VIEW


view : Maybe Point -> Model -> Html Msg
view currentGridPosition model =
    let
        gridSize =
            model.cellSize * model.size
    in
        div [ id [ GridStyles.GridContainer ] ]
            [ div [ id [ GridStyles.Grid ] ]
                [ Collage.collage gridSize
                    gridSize
                    [ backgroundGrid model
                        |> Collage.toForm
                    , entities model model.entities
                    , hoverBlock currentGridPosition model
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


entities : Model -> List Entity -> Collage.Form
entities model entityList =
    List.map (buildEntity model) entityList
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
                    |> addEntityOffset entity
                )


hoverBlock : Maybe Point -> Model -> Collage.Form
hoverBlock maybePoint model =
    case maybePoint of
        Just point ->
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
                                    |> addEntityOffset dummyEntity
                                )

        Nothing ->
            Collage.rect 0 0
                |> Collage.filled Color.black


backgroundGrid : Model -> Element.Element
backgroundGrid model =
    List.map (\row -> elementRow model.cellSize row) model.cells
        |> Element.flow Element.down


elementRow : Int -> List BackgroundCell -> Element.Element
elementRow size cells =
    List.map (\c -> Element.image size size c) cells
        |> Element.flow Element.right
