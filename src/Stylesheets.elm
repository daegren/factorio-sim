port module Stylesheets exposing (..)

import Css.File exposing (..)
import Grid.Styles as GridStyles
import SharedStyles
import ToolboxStyles
import BlueprintStyles


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure
        [ ( "styles.css"
          , compile
                [ SharedStyles.css
                , GridStyles.css
                , ToolboxStyles.css
                , BlueprintStyles.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
