module Grid.Update exposing (update)

import Grid.Model exposing (Cells, Model, Drag)
import Grid.Messages exposing (Msg(..))
import Random
import Grid
import Toolbox
import Point exposing (Point)
import Blueprint exposing (encodeBlueprint)


type alias Context =
    { model : Grid.Model.Model
    , toolbox : Toolbox.Model
    }



-- UPDATE


update : Msg -> Context -> ( Model, Cmd Msg )
update msg { model, toolbox } =
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
            ( { model | currentMouseGridPosition = Grid.positionToGridPoint model position }, Cmd.none )

        MouseEntered ->
            ( { model | mouseInsideGrid = True }, Cmd.none )

        MouseLeft ->
            ( { model | mouseInsideGrid = False, currentMouseGridPosition = Nothing }, Cmd.none )

        LoadBlueprint ->
            ( model, Grid.parseBlueprint model.blueprintString )

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
            ( model, Grid.exportBlueprint (encodeBlueprint model.entities) )

        ClearEntities ->
            ( { model | entities = [], blueprintString = "" }, Cmd.none )

        ReceiveExportedBlueprint blueprintString ->
            ( { model | blueprintString = blueprintString }, Cmd.none )

        ChangeGridSize amount ->
            let
                newSize =
                    model.size + amount
            in
                ( { model | size = newSize, shouldIgnoreNextMouseClick = True }, Random.generate RandomGrid (Grid.generateGrid newSize) )

        DragStart position ->
            case Grid.positionToGridPoint model position of
                Just point ->
                    ( { model | drag = Just (Drag point point) }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        DragAt position ->
            case Grid.positionToGridPoint model position of
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
                                Grid.placeEntityAtPoint toolbox drag.start model.entities
                            else
                                Grid.calculateLineBetweenPoints drag.start drag.current
                                    |> Grid.buildLineBetweenPoints (Toolbox.sizeFor toolbox.currentTool)
                                    |> List.foldl (\point entities -> Grid.placeEntityAtPoint toolbox point entities) model.entities
                    in
                        ( { model | drag = Nothing, entities = entities, currentMouseGridPosition = Grid.positionToGridPoint model position }, Grid.exportBlueprint (encodeBlueprint entities) )

                Nothing ->
                    ( { model | drag = Nothing }, Cmd.none )
