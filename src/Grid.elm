module Grid exposing (..)

import Html exposing (Html, div, h2, text)
import Collage exposing (traced, segment, solid, Form)
import Element
import Color
import Tile exposing (Tile)
import Size exposing (Size)
import Window
import Task exposing (perform)


-- MODEL


type alias Model =
    { tiles : List (List Tile)
    , size : Size
    }


initialModel : ( Model, Cmd Msg )
initialModel =
    let
        tiles =
            [ [] ]
    in
        ( Model tiles Size.emptySize
        , Cmd.batch
            [ perform SetWindowHeight Window.height
            , perform SetWindowWidth Window.width
            ]
        )



-- UPDATE


type Msg
    = SetWindowWidth Int
    | SetWindowHeight Int
    | WindowResize Window.Size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetWindowWidth width ->
            let
                size =
                    Size.setWidth width model.size
            in
                ( { model | size = size }, Cmd.none )

        SetWindowHeight height ->
            let
                size =
                    Size.setHeight (height - 123) model.size
            in
                ( { model | size = size }, Cmd.none )

        WindowResize size ->
            let
                newSize =
                    Size.rectangle size.width (size.height - 123)
            in
                ( { model | size = newSize }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Window.resizes WindowResize



-- VIEW


view : Model -> Html msg
view model =
    let
        size =
            model.size
    in
        Collage.collage size.width size.height [ drawGrid size ]
            |> Element.toHtml


gridSize : Float
gridSize =
    32.0


drawGrid : Size -> Form
drawGrid size =
    let
        width =
            toFloat size.width

        height =
            toFloat size.height

        rows =
            height / gridSize

        columns =
            width / gridSize

        columnSegments =
            List.range 0 (floor columns)
                |> List.map
                    (\r ->
                        let
                            x =
                                (toFloat r) * gridSize - width / 2

                            start =
                                ( x, height / 2 )

                            end =
                                ( x, -height / 2 )
                        in
                            segment start end
                    )

        rowSegments =
            List.range 0 (floor rows)
                |> List.map
                    (\r ->
                        let
                            y =
                                height / 2 - (toFloat r) * gridSize

                            start =
                                ( width / 2, y )

                            end =
                                ( -width / 2, y )
                        in
                            segment start end
                    )

        gridSegments =
            List.append rowSegments columnSegments

        form =
            List.map (\r -> traced (solid Color.grey) r) gridSegments
                |> Collage.group
    in
        form
