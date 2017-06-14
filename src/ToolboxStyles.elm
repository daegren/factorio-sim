module ToolboxStyles exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (img)


type Classes
    = Tool
    | CurrentTool
    | ToolList
    | Button
    | SelectedButton
    | ToolRow
    | ToolGroupItem
    | SelectedToolGroupItem


type Ids
    = Container
    | ToolboxItems
    | ToolGroup
    | ToolGroupContainer


css : Stylesheet
css =
    (stylesheet << namespace "toolbox")
        [ id Container
            [ border2 (px 1) solid
            , padding (px 8)
            , width (px 200)
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
            [ textAlign center
            , alignSelf center
            , backgroundImage (url "~assets/images/gui.png")
            , backgroundPosition2 (px 204) (px 148)
            , width (px 36)
            , height (px 36)
            , children
                [ img
                    [ width (px 32)
                    , height (px 32)
                    , padding2 (px 2) zero
                    ]
                ]
            ]
        , class SelectedButton [ backgroundPosition2 (px 204) zero ]
        , class CurrentTool [ margin (px 8) ]
        , class ToolList [ displayFlex ]
        , class ToolRow [ displayFlex ]
        , class ToolGroupItem
            [ backgroundImage (url "~assets/images/button-72.png")
            , backgroundPosition2 (px 0) (px -2)
            , margin2 zero (px 2)
            , width (px 72)
            , height (px 72)
            , children
                [ img [ width (px 68), height (px 68), padding (px 2) ] ]
            ]
        , class SelectedToolGroupItem [ backgroundPosition2 (px 74) (px -2) ]
        ]
