module ToolboxStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (img)


type Classes
    = Tool
    | CurrentTool


type Ids
    = Container
    | Toolbox


css : Stylesheet
css =
    (stylesheet << namespace "toolbox")
        [ id Container
            [ border2 (px 1) solid
            , margin2 (px 8) zero
            , padding (px 8)
            , width (px 200)
            ]
        , id Toolbox
            [ displayFlex
            , flexWrap wrap
            , justifyContent spaceAround
            , textAlign center
            ]
        , class Tool
            [ displayFlex
            , flexDirection column
            , margin (px 8)
            , flex2 zero zero
            , children
                [ img
                    [ textAlign center
                    , alignSelf center
                    , width (px 32)
                    , height (px 32)
                    ]
                ]
            ]
        , class CurrentTool
            [ margin (px 8)
            , children
                [ img
                    [ width (px 32)
                    , height (px 32)
                    ]
                ]
            ]
        ]
