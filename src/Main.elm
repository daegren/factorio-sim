module Main exposing (..)

import Material
import Html exposing (Html, h1, div, text, img)
import Html.Attributes exposing (src)
import Random exposing (Generator)
import GridStyles exposing (Classes(..))
import Html.CssHelpers


-- MODEL


type alias Model =
    { mdl : Material.Model
    , grid : Grid
    }


type alias Grid =
    List (List Cell)


type alias Cell =
    { image : String
    }


getGrassCell : Int -> Cell
getGrassCell num =
    Cell ("/assets/images/grass/" ++ (toString num) ++ ".png")


generateRandomGrassCell : Generator Cell
generateRandomGrassCell =
    Random.map (\i -> getGrassCell i) (Random.int 0 15)


generateGrid : Int -> Generator Grid
generateGrid size =
    Random.list size (Random.list size generateRandomGrassCell)



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model Material.model []
    , Random.generate RandomGrid (generateGrid 20)
    )



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = Mdl (Material.Msg Msg)
    | RandomGrid Grid


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl subMsg ->
            Material.update Mdl subMsg model

        RandomGrid grid ->
            ( { model | grid = grid }, Cmd.none )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "grid"



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ gridView model.grid ]


gridView : Grid -> Html msg
gridView grid =
    div [] (List.map buildRow grid)


buildRow : List Cell -> Html msg
buildRow row =
    div [ class [ Row ] ] (List.map buildCell row)


buildCell : Cell -> Html msg
buildCell cell =
    div [ class [ GridStyles.Cell ] ]
        [ img [ src cell.image ] []
        ]
