port module Main exposing (..)

import Html exposing (Html, h1, div, text, img)
import Html.Attributes exposing (src)
import Random exposing (Generator)
import GridStyles exposing (Classes(..))
import SharedStyles exposing (Classes(..))
import Html.CssHelpers
import Mouse


-- MODEL


type alias Model =
    { grid : Grid
    , offset : ( Int, Int )
    , mouseGridPosition : ( Int, Int )
    , currentMousePosition : ( Int, Int )
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
    ( Model [] ( 0, 0 ) ( 0, 0 ) ( 0, 0 )
    , Cmd.batch
        [ Random.generate RandomGrid (generateGrid 20)
        , getOffsetOfGrid ()
        ]
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
    Sub.batch
        [ receiveOffset GridOffset
        , Mouse.moves MouseMoved
        ]



-- UPDATE


type Msg
    = RandomGrid Grid
    | GridOffset ( Int, Int )
    | MouseMoved Mouse.Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomGrid grid ->
            ( { model | grid = grid }, Cmd.none )

        GridOffset offset ->
            ( { model | offset = offset }, Cmd.none )

        MouseMoved position ->
            let
                ( offsetX, offsetY ) =
                    model.offset

                gridSize =
                    20

                x =
                    floor ((toFloat (position.x - offsetX)) / 32)
                        |> clamp 0 (gridSize - 1)

                y =
                    floor ((toFloat (position.y - offsetY)) / 32)
                        |> clamp 0 (gridSize - 1)
            in
                ( { model
                    | currentMousePosition = ( position.x, position.y )
                    , mouseGridPosition = ( x, y )
                  }
                , Cmd.none
                )



-- PORTS


port getOffsetOfGrid : () -> Cmd msg


port receiveOffset : (( Int, Int ) -> msg) -> Sub msg



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "grid"



-- VIEW


view : Model -> Html Msg
view model =
    div [ id [ Main ] ]
        [ gridView model.grid
        , infoView model
        ]


infoView : Model -> Html msg
infoView model =
    div [ id [ Info ] ]
        [ h1 [] [ text "Factorio Simulator" ]
        , div []
            [ text "Current Mouse Position: "
            , pointView model.currentMousePosition
            ]
        , div []
            [ text "Current Grid Position: "
            , pointView model.mouseGridPosition
            ]
        ]


pointView : ( Int, Int ) -> Html msg
pointView ( x, y ) =
    let
        pointText =
            "{ " ++ (toString x) ++ ", " ++ (toString y) ++ " }"
    in
        div [] [ text pointText ]


gridView : Grid -> Html msg
gridView grid =
    div [ id [ Grid ] ] (List.map buildRow grid)


buildRow : List Cell -> Html msg
buildRow row =
    div [ class [ Row ] ] (List.map buildCell row)


buildCell : Cell -> Html msg
buildCell cell =
    div [ class [ GridStyles.Cell ] ]
        [ img [ src cell.image ] []
        ]
