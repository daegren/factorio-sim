module Game exposing (..)

import Html exposing (Html, div, text)
import Grid
import Grid.Model as GridModel
import Grid.Messages
import Grid.View as GridView
import Grid.Update as GridUpdate
import Toolbox


-- MODEL


type alias Model =
    { grid : GridModel.Model
    , toolbox : Toolbox.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( gridModel, gridCmd ) =
            Grid.init
    in
        ( { grid = gridModel
          , toolbox = Toolbox.initialModel
          }
        , Cmd.map GridMsg gridCmd
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map GridMsg (Grid.subscriptions model.grid)
        , Sub.map ToolboxMsg (Toolbox.subscriptions model.toolbox)
        ]



-- UPDATE


type Msg
    = GridMsg Grid.Messages.Msg
    | ToolboxMsg Toolbox.Msg


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



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.map GridMsg (GridView.view { model = model.grid, toolbox = model.toolbox })
        , Html.map ToolboxMsg (Toolbox.view model.toolbox)
        ]
