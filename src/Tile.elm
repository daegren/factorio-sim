module Tile exposing (..)

import Random exposing (Generator, int, map)


type alias Tile =
    { image : String
    }


getGrassTile : Int -> Tile
getGrassTile num =
    Tile ("/assets/images/grass/" ++ toString num ++ ".png")


getRandomGrassTile : Generator Tile
getRandomGrassTile =
    map (\i -> getGrassTile i) (int 0 15)
