module SharedStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = Main


css : Stylesheet
css =
    (stylesheet << namespace "main")
        [ id Main
            [ displayFlex ]
        ]
