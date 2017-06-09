module SharedStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = Main
    | Copyright


css : Stylesheet
css =
    (stylesheet << namespace "main")
        [ id Main
            []
        , id Copyright
            [ margin2 (px 20) zero ]
        ]
