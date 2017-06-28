module Grid.Update exposing (update)

import Grid.Model exposing (Cells, Model, Drag)
import Grid.Messages exposing (Msg(..))
import Entity
import Entity.Picker
import Random
import Grid
import Tool
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
            ( { model | entities = [], blueprintString = "" }, Cmd.none )

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
                                Grid.placeEntityAtPoint tools picker drag.start model.entities
                            else
                                Grid.calculateLineBetweenPoints drag.start drag.current
                                    |> Grid.buildLineBetweenPoints (Entity.sizeFor picker.currentEntity)
                                    |> List.foldl (\point entities -> Grid.placeEntityAtPoint tools picker point entities) model.entities
                    in
                        ( { model | drag = Nothing, entities = entities, currentMouseGridPosition = Grid.positionToGridPoint model position }, Blueprint.exportBlueprint (encodeBlueprint entities) )

                Nothing ->
                    ( { model | drag = Nothing }, Cmd.none )
