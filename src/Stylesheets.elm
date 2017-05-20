port module Stylesheets exposing (..)

import Css.File exposing (..)
import GridStyles
import SharedStyles
import ToolboxStyles


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure
        [ ( "styles.css"
          , compile
                [ SharedStyles.css
                , GridStyles.css
                , ToolboxStyles.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
