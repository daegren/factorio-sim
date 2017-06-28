port module Stylesheets exposing (..)

import Css.File exposing (..)
import Grid.Styles as GridStyles
import SharedStyles
import BlueprintStyles
import Tools
import Entity.PickerStyles


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
                , Tools.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
