module SharedStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = Main
    | Copyright


type Ids
    = MainContainer
    | GridContainer
    | ToolboxContainer
    | BlueprintContainer
    | Sidebar


css : Stylesheet
css =
    (stylesheet << namespace "main")
        [ id Main
            []
        , id Copyright
            [ margin2 (px 20) zero ]
        , id MainContainer
            [ displayFlex ]
        , id GridContainer
            [ flex2 (num 1) zero ]
        , id Sidebar
            [ flex2 zero zero ]
        ]
