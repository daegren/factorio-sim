module Entity exposing (..)


type alias Position =
    { x : Float
    , y : Float
    }


type alias Entity =
    { name : EntityName
    , position : Position
    , direction : Direction
    }


type EntityName
    = TransportBelt
    | Other String


type Direction
    = Up
    | Right
    | Down
    | Left


direction : Maybe Int -> Direction
direction int =
    case int of
        Just dir ->
            case dir of
                4 ->
                    Down

                2 ->
                    Right

                6 ->
                    Left

                _ ->
                    Debug.crash "Found wrong direction."

        Nothing ->
            Up


entityName : String -> EntityName
entityName name =
    case name of
        "transport-belt" ->
            TransportBelt

        _ ->
            Other name
