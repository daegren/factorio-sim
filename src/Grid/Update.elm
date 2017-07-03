module Grid.Update exposing (update)

import Grid.Model exposing (Cells, Model, Drag)
import Grid.Messages exposing (Msg(..))
import Ports
import Entity
import Entity.Picker
import Random
import Grid
import Tool exposing (Tool(..))
import Point exposing (Point)
import Blueprint exposing (encodeBlueprint)


type alias Context =
    { model : Grid.Model.Model
    , tools : Tool.Model
    , picker : Entity.Picker.Model
    }



-- UPDATE


update : Msg -> Context -> ( Model, Cmd Msg )
update msg { model, tools, picker } =
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

        ClearEntities ->
            ( { model | entities = [] }, Cmd.none )

        ChangeGridSize amount ->
            let
                newSize =
                    model.size + amount
            in
                ( { model | size = newSize }, Random.generate RandomGrid (Grid.generateGrid newSize) )

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
                        newModel =
                            case tools.currentTool of
                                Place ->
                                    let
                                        entity =
                                            Entity.entity picker.currentEntity tools.currentDirection

                                        entities =
                                            Grid.calculateLineBetweenPoints drag.start drag.current
                                                |> Grid.buildLineBetweenPoints (Entity.sizeFor picker.currentEntity)
                                                |> List.foldl (\point entities -> Grid.addEntity (Entity.setPosition (Entity.positionFromPoint point) entity) entities) model.entities
                                    in
                                        { model | entities = entities }

                                Clear ->
                                    let
                                        entities =
                                            Grid.calculateLineBetweenPoints drag.start drag.current
                                                |> Grid.buildLineBetweenPoints (Entity.Square 1)
                                                |> List.foldl (\point entities -> Grid.removeEntityAtPoint point entities) model.entities
                                    in
                                        { model | entities = entities }

                                SetRecipe ->
                                    let
                                        allowedEntities =
                                            [ Entity.AssemblingMachine1, Entity.AssemblingMachine2, Entity.AssemblingMachine3 ]
                                    in
                                        case Grid.getEntityAtPoint drag.current model.entities of
                                            Just entity ->
                                                if List.member entity.name allowedEntities then
                                                    { model | entities = Grid.updateEntity { entity | recipe = Just picker.currentEntity } model.entities }
                                                else
                                                    model

                                            Nothing ->
                                                model
                    in
                        ( { newModel | drag = Nothing, currentMouseGridPosition = Grid.positionToGridPoint model position }, Ports.exportBlueprint (encodeBlueprint newModel.entities) )

                Nothing ->
                    ( { model | drag = Nothing }, Cmd.none )

        ToggleDebug ->
            ( { model | debug = not model.debug }, Cmd.none )
