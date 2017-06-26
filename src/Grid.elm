port module Grid exposing (..)

import Entity.Decoder
import Json.Decode exposing (Value)
import Point exposing (Point, zeroPoint)
import Random exposing (Generator)
import Mouse
import Toolbox exposing (Tool(..))
import Entity exposing (Entity, Size(..))
import Json.Decode as Json
import Grid.Model exposing (Model, BackgroundCell, Cells)
import Grid.Messages exposing (Msg(..))


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
            Grid.Model.emptyGrid
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



-- HELPERS


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


{-| Builds a straight line between the given points, accounting for an entity size.

Assumes the points are aligned on either the x or y axis.

    buildLineBetweenPoints (Square 1) ( Point 0 -1, Point 0 1) == [ Point 0 -1, Point 0 0, Point 0 1 ]
    buildLineBetweenPoints (Square 3) ( Point 0 -1 , Point 0 2) == [ Point 0 -1, Point 0 2 ]
-}
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
