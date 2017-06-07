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


directionToInt : Direction -> Maybe Int
directionToInt direction =
    case direction of
        Down ->
            Just 4

        Right ->
            Just 2

        Left ->
            Just 6

        Up ->
            Nothing


entityName : String -> EntityName
entityName name =
    case name of
        "transport-belt" ->
            TransportBelt

        _ ->
            Other name


nameToString : EntityName -> String
nameToString entityName =
    case entityName of
        TransportBelt ->
            "transport-belt"

        Other str ->
            str
