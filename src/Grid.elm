module Grid exposing (..)

import Html exposing (Html, div, h2, text)
import Collage exposing (traced, segment, solid, Form)
import Element
import Color
import Tile exposing (Tile)
import Size exposing (Size)
import Random exposing (Generator)


-- MODEL


type alias Model =
    { tiles : List (List Tile)
    , size : Size
    }


initialModel : ( Model, Cmd Msg )
initialModel =
    let
        size =
            20

        tiles =
            [ [] ]
    in
        ( Model tiles (Size.square (floor (gridSize * size)))
        , Random.generate GenerateBackgroundTiles (generateBackgroundTiles size)
        )



-- UPDATE


type Msg
    = GenerateBackgroundTiles (List (List Tile))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateBackgroundTiles tiles ->
            ( { model | tiles = tiles }, Cmd.none )



generateBackgroundTiles : Int -> Generator (List (List Tile))
generateBackgroundTiles size =
    Random.list size <| Random.list size Tile.getRandomGrassTile



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Sub.none



-- VIEW


view : Model -> Html msg
view model =
    Collage.collage model.size.width
        model.size.height
        [ drawBackgroundTiles model ]
        |> Element.toHtml


gridSize : Float
gridSize =
    32.0


drawBackgroundTiles : Model -> Form
drawBackgroundTiles model =
    let
        size =
            model.size

        width =
            toFloat size.width

        height =
            toFloat size.height

        rows =
            height / gridSize

        columns =
            width / gridSize

        tiles =
            model.tiles
                |> List.indexedMap
                    (\rid r ->
                        r
                            |> List.indexedMap
                                (\cid c ->
                                    let
                                        tileSize =
                                            floor gridSize

                                        element =
                                            Element.image tileSize tileSize c.image

                                        position =
                                            ( (toFloat rid) * gridSize - width / 2 + gridSize / 2
                                            , height / 2 - (toFloat cid) * gridSize - gridSize / 2
                                            )

                                        form =
                                            Collage.toForm element
                                                |> Collage.move position
                                    in
                                        form
                                )
                    )
                |> List.concat
    in
        Collage.group tiles


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
