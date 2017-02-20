module Grid exposing (..)

import Html exposing (Html, div, h2, text)
import Collage exposing (traced, segment, solid, Form)
import Element
import Color
import Size exposing (Size)


    }




view : Size -> Html msg
view size =
    Collage.collage size.width size.height [ drawGrid size ]
        |> Element.toHtml


drawGrid : Size -> Form
drawGrid size =
    let
        width =
            toFloat size.width

        height =
            toFloat size.height

        gridSize =
            25.0

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
