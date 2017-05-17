module GridStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Colors exposing (yellow)


type Classes
    = Row
    | Cell


css : Stylesheet
css =
    (stylesheet << namespace "grid")
        [ class Row
            [ displayFlex ]
        , class Cell
            [ width (px 32)
            , height (px 32)
            , hover
                [ before
                    [ property "content" "''"
                    , position absolute
                    , backgroundColor yellow
                    , opacity (num 0.25)
                    , width (px 32)
                    , height (px 32)
                    ]
                ]
            ]
        ]
