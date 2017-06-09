module GridStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Colors exposing (yellow)


type Classes
    = Row
    | Cell


type Ids
    = GridContainer
    | Grid
    | Toolbox


css : Stylesheet
css =
    (stylesheet << namespace "grid")
        [ id GridContainer
            [ displayFlex ]
        , id Grid
            [ flex2 (int 0) (int 0)
            , margin2 (px 8) (px 8)
            ]
        , id Toolbox
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
