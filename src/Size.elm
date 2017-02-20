module Size exposing (..)


type alias Size =
    { width : Int
    , height : Int
    }


square : Int -> Size
square side =
    Size side side


rectangle : Int -> Int -> Size
rectangle width height =
    Size width height


emptySize : Size
emptySize =
    square 0


setWidth : Int -> Size -> Size
setWidth width size =
    { size | width = width }


setHeight : Int -> Size -> Size
setHeight height size =
    { size | height = height }
