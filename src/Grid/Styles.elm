module Grid.Styles exposing (..)

import Css exposing (..)
import Css.Colors exposing (yellow)
import Css.Namespace exposing (namespace)


type Classes
    = Row
    | Cell
    | Input


type Ids
    = GridContainer
    | Grid
    | Toolbox
    | BlueprintInput


css : Stylesheet
css =
    (stylesheet << namespace "grid")
        [ id Grid
            [ flex2 (int 0) (int 0)
            , paddingRight (px 8)
            ]
        , id Toolbox
            [ flex2 (int 1) (int 0)
            , flexBasis auto
            , marginLeft (px 24)
            ]
        , id BlueprintInput
            [ margin2 (px 8) zero
            , children
                [ class Input
                    [ width (pct 100)
                    , height (px 150)
                    ]
                ]
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
