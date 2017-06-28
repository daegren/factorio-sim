module Game exposing (..)

import Html exposing (Html, div, text)
import Grid
import Grid.Model as GridModel
import Grid.Messages
import Grid.View as GridView
import Grid.Update as GridUpdate
import Toolbox
import SharedStyles exposing (Ids(..))
import Blueprint
import Html.CssHelpers


-- MODEL


type alias Model =
    { grid : GridModel.Model
    , toolbox : Toolbox.Model
    , blueprint : Blueprint.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( gridModel, gridCmd ) =
            Grid.init
    in
        ( { grid = gridModel
          , toolbox = Toolbox.initialModel
          , blueprint = Blueprint.init
          }
        , Cmd.map GridMsg gridCmd
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map GridMsg (Grid.subscriptions model.grid)
        , Sub.map ToolboxMsg (Toolbox.subscriptions model.toolbox)
        , Sub.map BlueprintMsg (Blueprint.subscriptions model.blueprint)
        ]



-- UPDATE


type Msg
    = GridMsg Grid.Messages.Msg
    | ToolboxMsg Toolbox.Msg
    | BlueprintMsg Blueprint.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GridMsg msg ->
            let
                ( gridModel, gridCmd ) =
                    GridUpdate.update msg { model = model.grid, toolbox = model.toolbox }
            in
                ( { model | grid = gridModel }, Cmd.map GridMsg gridCmd )

        ToolboxMsg msg ->
            let
                ( toolboxModel, toolboxCmd ) =
                    Toolbox.update msg model.toolbox
            in
                ( { model | toolbox = toolboxModel }, Cmd.map ToolboxMsg toolboxCmd )

        BlueprintMsg msg ->
            let
                ( blueprintModel, blueprintCmd ) =
                    Blueprint.update msg { model = model.blueprint, entities = model.grid.entities }
            in
                ( { model | blueprint = blueprintModel }, Cmd.map BlueprintMsg blueprintCmd )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "main"



-- VIEW


view : Model -> Html Msg
view model =
    div [ id [ MainContainer ] ]
        [ div [ id [ GridContainer ] ] [ Html.map GridMsg (GridView.view { model = model.grid, toolbox = model.toolbox }) ]
        , div [ id [ Sidebar ] ]
            [ div [ id [ ToolboxContainer ] ] [ Html.map ToolboxMsg (Toolbox.view model.toolbox) ]
            , div [ id [ BlueprintContainer ] ] [ Html.map BlueprintMsg (Blueprint.view model.blueprint) ]
            ]
        ]
