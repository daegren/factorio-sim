module Game exposing (..)

import Html exposing (Html, div, text)
import Grid
import Grid.Model as GridModel
import Grid.Messages
import Grid.View as GridView
import Grid.Update as GridUpdate


-- MODEL


type alias Model =
    { grid : GridModel.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( gridModel, gridCmd ) =
            Grid.init
    in
        ( { grid = gridModel }, Cmd.map GridMsg gridCmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map GridMsg (Grid.subscriptions model.grid)



-- UPDATE


type Msg
    = GridMsg Grid.Messages.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GridMsg msg ->
            let
                ( gridModel, gridCmd ) =
                    GridUpdate.update msg model.grid
            in
                ( { model | grid = gridModel }, Cmd.map GridMsg gridCmd )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.map GridMsg (GridView.view model.grid)
        ]
