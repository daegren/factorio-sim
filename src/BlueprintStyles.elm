module BlueprintStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = Input


css : Stylesheet
css =
    (stylesheet << namespace "blueprint")
        [ class Input
            [ width (pct 100)
            , height (px 150)
            ]
        ]
