module GridStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


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
            ]
        ]
