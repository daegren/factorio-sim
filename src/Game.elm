module Game exposing (..)

import Blueprint
import Entity.Picker
import Grid
import Grid.Messages
import Grid.Model as GridModel
import Grid.Update as GridUpdate
import Grid.View as GridView
import Html exposing (Html, div, text)
import Html.CssHelpers
import SharedStyles exposing (Ids(..))
import Tool


-- MODEL


type alias Model =
    { grid : GridModel.Model
    , blueprint : Blueprint.Model
    , tools : Tool.Model
    , picker : Entity.Picker.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( gridModel, gridCmd ) =
            Grid.init
    in
    ( { grid = gridModel
      , blueprint = Blueprint.init
      , tools = Tool.init
      , picker = Entity.Picker.init
      }
    , Cmd.map GridMsg gridCmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map GridMsg (Grid.subscriptions model.grid)
        , Sub.map ToolMsg (Tool.subscriptions model.tools)
        , Sub.map BlueprintMsg (Blueprint.subscriptions model.blueprint)
        ]



-- UPDATE


type Msg
    = GridMsg Grid.Messages.Msg
    | PickerMsg Entity.Picker.Msg
    | BlueprintMsg Blueprint.Msg
    | ToolMsg Tool.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GridMsg msg ->
            let
                ( gridModel, gridCmd ) =
                    GridUpdate.update msg { model = model.grid, tools = model.tools, picker = model.picker }
            in
            ( { model | grid = gridModel }, Cmd.map GridMsg gridCmd )

        PickerMsg msg ->
            let
                ( pickerModel, pickerCmd ) =
                    Entity.Picker.update msg model.picker
            in
            ( { model | picker = pickerModel }, Cmd.map PickerMsg pickerCmd )

        BlueprintMsg msg ->
            let
                ( blueprintModel, blueprintCmd ) =
                    Blueprint.update msg { model = model.blueprint, entities = model.grid.entities }
            in
            ( { model | blueprint = blueprintModel }, Cmd.map BlueprintMsg blueprintCmd )

        ToolMsg msg ->
            let
                ( toolsModel, toolsCmd ) =
                    Tool.update msg model.tools
            in
            ( { model | tools = toolsModel }, Cmd.map ToolMsg toolsCmd )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "main"



-- VIEW


view : Model -> Html Msg
view model =
    div [ id [ MainContainer ] ]
        [ div [ id [ ToolContainer ] ] [ Html.map ToolMsg (Tool.view model.tools) ]
        , div [ id [ GridContainer ] ] [ Html.map GridMsg (GridView.view { model = model.grid, tools = model.tools, picker = model.picker }) ]
        , div [ id [ Sidebar ] ]
            [ div [ id [ ToolboxContainer ] ] [ Html.map PickerMsg (Entity.Picker.view model.picker) ]
            , div [ id [ BlueprintContainer ] ] [ Html.map BlueprintMsg (Blueprint.view model.blueprint) ]
            ]
        ]
