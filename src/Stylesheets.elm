port module Stylesheets exposing (..)

import BlueprintStyles
import Css.File exposing (..)
import Entity.PickerStyles
import Grid.Styles as GridStyles
import SharedStyles
import Tool


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure
        [ ( "styles.css"
          , compile
                [ SharedStyles.css
                , GridStyles.css
                , Entity.PickerStyles.css
                , BlueprintStyles.css
                , Tool.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
