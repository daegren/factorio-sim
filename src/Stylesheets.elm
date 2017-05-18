port module Stylesheets exposing (..)

import Css.File exposing (..)
import GridStyles
import SharedStyles


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure [ ( "styles.css", compile [ SharedStyles.css, GridStyles.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
