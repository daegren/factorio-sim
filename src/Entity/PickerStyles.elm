module Entity.PickerStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (img)


type Classes
    = Tool
    | CurrentTool
    | EntityList
    | Button
    | SelectedButton
    | ToolRow
    | Item
    | SelectedItem


type Ids
    = Container
    | ToolboxItems
    | ToolGroup
    | ToolGroupContainer


css : Stylesheet
css =
    (stylesheet << namespace "picker")
        [ id Container
            [ border2 (px 1) solid
            , padding (px 8)
            , displayFlex
            ]
        , id ToolboxItems
            [ displayFlex
            , flexWrap wrap
            , textAlign center
            , margin2 (px 8) zero
            , flexDirection column
            ]
        , id ToolGroup [ displayFlex ]
        , id ToolGroupContainer
            [ backgroundColor (hex "#888")
            , padding (px 4)
            , margin2 (px 4) zero
            ]
        , class Tool [ flex2 zero zero ]
        , class Button
            [ width (px 36)
            , height (px 36)
            , textAlign center
            , verticalAlign center
            , backgroundImage (url "~assets/images/button-36.png")
            , backgroundPosition2 (px -2) zero
            , children
                [ img
                    [ width (px 30)
                    , height (px 30)
                    , margin2 (px 4) (px 3)
                    ]
                ]
            ]
        , class SelectedButton
            [ backgroundPosition2 (px -40) (px 1) ]
        , class CurrentTool [ margin (px 8) ]
        , class EntityList [ displayFlex ]
        , class ToolRow [ displayFlex ]
        , class Item
            [ backgroundImage (url "~assets/images/button-72.png")
            , backgroundPosition2 (px 0) (px -2)
            , margin2 zero (px 2)
            , width (px 72)
            , height (px 72)
            , children
                [ img [ width (px 68), height (px 68), padding (px 2) ] ]
            ]
        , class SelectedItem [ backgroundPosition2 (px 74) (px -2) ]
        ]
