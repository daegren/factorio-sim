module GridStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Colors exposing (yellow)


type Classes
    = Row
    | Cell


type Ids
    = Grid
    | Info


css : Stylesheet
css =
    (stylesheet << namespace "grid")
        [ id Grid
            [ flex2 (int 0) (int 0) ]
        , id Info
            [ flex2 (int 1) (int 0)
            , flexBasis auto
            , marginLeft (px 24)
            ]
        , class Row
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
