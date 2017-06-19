port module Grid exposing (..)

import Html exposing (Html, div, input, textarea, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave, onWithOptions)
import Html.CssHelpers
import Css
import GridStyles exposing (Classes(..))
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
import Blueprint exposing (encodeBlueprint)
import Json.Decode as Json


-- MODEL


type alias Model =
    { cells : Cells
    , entities : List Entity
    , cellSize : Int
    , size : Int
    , offset : Point
    , blueprintString : String
    , toolbox : Toolbox.Model
    , shouldIgnoreNextMouseClick : Bool
    , mouseInsideGrid : Bool
    , currentMouseGridPosition : Maybe Point
    , mouseStartPosition : Maybe Point
    , drag : Maybe Drag
    }


emptyGrid : Model
emptyGrid =
    Model [] [] 32 15 zeroPoint "" Toolbox.initialModel False False Nothing Nothing Nothing


type alias Drag =
    { start : Point
    , current : Point
    }


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
        , loadBlueprint (Json.Decode.decodeValue (Json.Decode.list Entity.Decoder.decodeEntity) >> SentBlueprint)
        , Sub.map ToolboxMsg (Toolbox.subscriptions model.toolbox)
        , receiveExportedBlueprint ReceiveExportedBlueprint
        , shouldSubToMouseSubscriptions model
        , dragSubscriptions model
        ]


shouldSubToMouseSubscriptions : Model -> Sub Msg
shouldSubToMouseSubscriptions model =
    if model.mouseInsideGrid && model.drag == Nothing then
        Mouse.moves MouseMoved
    else
        Sub.none


dragSubscriptions : Model -> Sub Msg
dragSubscriptions model =
    case model.drag of
        Just drag ->
            Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd ]

        Nothing ->
            Sub.none



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
    | MouseMoved Mouse.Position
    | MouseEntered
    | MouseLeft
    | LoadBlueprint
    | BlueprintChanged String
    | SentBlueprint (Result String (List Entity))
    | ExportBlueprint
    | ClearEntities
    | ReceiveExportedBlueprint String
    | ChangeGridSize Int
    | DragStart Mouse.Position
    | DragAt Mouse.Position
    | DragEnd Mouse.Position
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

        MouseMoved position ->
            ( { model | currentMouseGridPosition = positionToGridPoint model position }, Cmd.none )

        MouseEntered ->
            ( { model | mouseInsideGrid = True }, Cmd.none )

        MouseLeft ->
            ( { model | mouseInsideGrid = False, currentMouseGridPosition = Nothing }, Cmd.none )

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
            ( model, exportBlueprint (encodeBlueprint model.entities) )

        ClearEntities ->
            ( { model | entities = [], blueprintString = "" }, Cmd.none )

        ReceiveExportedBlueprint blueprintString ->
            ( { model | blueprintString = blueprintString }, Cmd.none )

        ChangeGridSize amount ->
            let
                newSize =
                    model.size + amount
            in
                ( { model | size = newSize, shouldIgnoreNextMouseClick = True }, Random.generate RandomGrid (generateGrid newSize) )

        DragStart position ->
            case positionToGridPoint model position of
                Just point ->
                    ( { model | drag = Just (Drag point point) }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        DragAt position ->
            case positionToGridPoint model position of
                Just point ->
                    ( { model | drag = Maybe.map (\{ start } -> Drag start point) model.drag }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        DragEnd position ->
            case model.drag of
                Just drag ->
                    let
                        entities =
                            if drag.start == drag.current then
                                placeEntityAtPoint model.toolbox drag.start model.entities
                            else
                                calculateLineBetweenPoints drag.start drag.current
                                    |> buildLineBetweenPoints (Toolbox.sizeFor model.toolbox.currentTool)
                                    |> List.foldl (\point entities -> placeEntityAtPoint model.toolbox point entities) model.entities
                    in
                        ( { model | drag = Nothing, entities = entities }, exportBlueprint (encodeBlueprint entities) )

                Nothing ->
                    ( { model | drag = Nothing }, Cmd.none )

        ToolboxMsg msg ->
            let
                ( toolboxModel, toolboxCmd ) =
                    Toolbox.update msg model.toolbox
            in
                ( { model | toolbox = toolboxModel }, Cmd.map ToolboxMsg toolboxCmd )


calculateLineBetweenPoints : Point -> Point -> ( Point, Point )
calculateLineBetweenPoints startPoint endPoint =
    let
        deltaX =
            abs (startPoint.x - endPoint.x)

        deltaY =
            abs (startPoint.y - endPoint.y)
    in
        if deltaX > deltaY then
            ( startPoint, Point endPoint.x startPoint.y )
        else
            ( startPoint, Point startPoint.x endPoint.y )


buildLineBetweenPoints : Entity.Size -> ( Point, Point ) -> List Point
buildLineBetweenPoints size ( start, end ) =
    let
        offset =
            case size of
                Square i ->
                    i
    in
        if start.x == end.x then
            let
                range =
                    if start.y < end.y then
                        List.range start.y end.y
                    else
                        List.range end.y start.y
                            |> List.reverse
            in
                every offset range
                    |> List.map (\y -> Point start.x y)
        else
            let
                range =
                    if start.x < end.x then
                        List.range start.x end.x
                    else
                        List.range end.x start.x
                            |> List.reverse
            in
                every offset range
                    |> List.map (\x -> Point x start.y)


every : Int -> List a -> List a
every amount list =
    List.indexedMap (,) list
        |> List.filter (\( i, val ) -> i % amount == 0)
        |> List.map (\( i, val ) -> val)


placeEntityAtPoint : Toolbox.Model -> Point -> List Entity -> List Entity
placeEntityAtPoint toolbox point entities =
    case toolbox.currentTool of
        Placeable entity ->
            let
                newEntity =
                    { entity | position = Entity.positionFromPoint point, direction = toolbox.currentDirection }
            in
                addEntity newEntity entities

        Clear ->
            removeEntityAtPoint point entities


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
addEntityOffset : Model -> Entity -> ( Float, Float ) -> ( Float, Float )
addEntityOffset { cellSize } entity ( x, y ) =
    let
        ( imageSizeX, imageSizeY ) =
            Entity.Image.sizeFor entity
    in
        case Entity.sizeFor entity of
            Square size ->
                ( x + (toFloat imageSizeX - toFloat cellSize * toFloat size) / 2, y + (toFloat imageSizeY - toFloat cellSize * toFloat size) / 2 )



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
                        |> Collage.toForm
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
                calculateLineBetweenPoints drag.start drag.current
                    |> buildLineBetweenPoints (Toolbox.sizeFor model.toolbox.currentTool)
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


backgroundGrid : Model -> Element.Element
backgroundGrid model =
    List.map (\row -> elementRow model.cellSize row) model.cells
        |> Element.flow Element.down


elementRow : Int -> List BackgroundCell -> Element.Element
elementRow size cells =
    List.map (\c -> Element.image size size c) cells
        |> Element.flow Element.right
