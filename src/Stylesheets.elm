port module Stylesheets exposing (..)

import Css.File exposing (..)
import GridStyles


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure [ ( "styles.css", compile [ GridStyles.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
