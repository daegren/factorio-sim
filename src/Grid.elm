module Grid exposing (..)

import Html exposing (Html, div, h2, text)
import Collage exposing (traced, segment, solid, Form)
import Element
import Color


view : Html msg
view =
    div []
        [ h2 [] [ text "Grid" ]
        , Collage.collage 400 400 [ drawGrid ]
            |> Element.toHtml
        ]


drawGrid : Form
drawGrid =
    let
        width =
            400.0

        height =
            400.0

        gridSize =
            25.0

        rows =
            width / gridSize

        columns =
            height / gridSize

        rowSegements =
            List.range 0 (floor rows)
                |> List.map
                    (\r ->
                        let
                            x =
                                (toFloat r) * gridSize - height / 2

                            start =
                                ( x, -height / 2 )

                            end =
                                ( x, height / 2 )
                        in
                            segment start end
                    )

        columnSegments =
            List.range 0 (floor columns)
                |> List.map
                    (\r ->
                        let
                            y =
                                (toFloat r) * gridSize - width / 2

                            start =
                                ( -width / 2, y )

                            end =
                                ( width / 2, y )
                        in
                            segment start end
                    )

        gridSegments =
            List.append rowSegements columnSegments

        form =
            List.map (\r -> traced (solid Color.black) r) gridSegments
                |> Collage.group
    in
        form
