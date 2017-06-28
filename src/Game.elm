module Game exposing (..)

import Html exposing (Html, div, text)
import Grid
import Grid.Model as GridModel
import Grid.Messages
import Grid.View as GridView
import Grid.Update as GridUpdate
import SharedStyles exposing (Ids(..))
import Entity.Picker
import Tools
import Blueprint
import Html.CssHelpers


-- MODEL


type alias Model =
    { grid : GridModel.Model
    , blueprint : Blueprint.Model
    , tools : Tools.Model
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
          , tools = Tools.init
          , picker = Entity.Picker.init
          }
        , Cmd.map GridMsg gridCmd
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map GridMsg (Grid.subscriptions model.grid)
        , Sub.map ToolsMsg (Tools.subscriptions model.tools)
        , Sub.map BlueprintMsg (Blueprint.subscriptions model.blueprint)
        ]



-- UPDATE


type Msg
    = GridMsg Grid.Messages.Msg
    | PickerMsg Entity.Picker.Msg
    | BlueprintMsg Blueprint.Msg
    | ToolsMsg Tools.Msg


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

        ToolsMsg msg ->
            let
                ( toolsModel, toolsCmd ) =
                    Tools.update msg model.tools
            in
                ( { model | tools = toolsModel }, Cmd.map ToolsMsg toolsCmd )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "main"



-- VIEW


view : Model -> Html Msg
view model =
    div [ id [ MainContainer ] ]
        [ div [ id [ ToolContainer ] ] [ Html.map ToolsMsg (Tools.view model.tools) ]
        , div [ id [ GridContainer ] ] [ Html.map GridMsg (GridView.view { model = model.grid, tools = model.tools, picker = model.picker }) ]
        , div [ id [ Sidebar ] ]
            [ div [ id [ ToolboxContainer ] ] [ Html.map PickerMsg (Entity.Picker.view model.picker) ]
            , div [ id [ BlueprintContainer ] ] [ Html.map BlueprintMsg (Blueprint.view model.blueprint) ]
            ]
        ]
