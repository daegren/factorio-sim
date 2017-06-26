port module Blueprint exposing (..)

import Json.Encode exposing (..)
import Entity exposing (Entity, EntityName)
import Entity.Encoder exposing (encodeEntities)
import Html exposing (Html, div, textarea, input)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput)


-- MODEL


type alias Model =
    String


type alias Icon =
    ( Int, EntityName )


init : Model
init =
    ""


encodeBlueprint : List Entity -> Value
encodeBlueprint entities =
    object
        [ ( "blueprint"
          , object
                [ ( "entities", encodeEntities entities )
                , ( "icons", icons entities |> encodeIcons )
                , ( "item", string "blueprint" )
                , ( "version", int 64425689088 )
                ]
          )
        ]


encodeIcons : List Icon -> Value
encodeIcons icons =
    List.take 4 icons
        |> List.indexedMap encodeIcon
        |> list


encodeIcon : Int -> Icon -> Value
encodeIcon idx ( count, name ) =
    object
        [ ( "signal"
          , object
                [ ( "type", string "item" )
                , ( "name", string (Entity.entityIDFromName name) )
                ]
          )
        , ( "index", int (idx + 1) )
        ]


icons : List Entity -> List Icon
icons entities =
    (List.foldl entityToIcon [] entities)
        |> List.sortWith sortIcons


sortIcons : Icon -> Icon -> Order
sortIcons ( a, _ ) ( b, _ ) =
    case compare a b of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT


entityToIcon : Entity -> List Icon -> List Icon
entityToIcon entity icons =
    case getIcon entity icons of
        Just ( count, name ) ->
            List.map
                (\( aCount, aName ) ->
                    if name == aName then
                        ( aCount + 1, aName )
                    else
                        ( aCount, aName )
                )
                icons

        Nothing ->
            ( 1, entity.name ) :: icons


getIcon : Entity -> List Icon -> Maybe Icon
getIcon entity icons =
    List.filter (\( int, name ) -> name == entity.name) icons
        |> List.head



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveExportedBlueprint ReceiveExportedBlueprint



-- PORTS


port parseBlueprint : String -> Cmd msg


port exportBlueprint : Value -> Cmd msg


port receiveExportedBlueprint : (String -> msg) -> Sub msg



-- UPDATE


type alias Context =
    { model : Model
    , entities : List Entity
    }


type Msg
    = Changed Model
    | Load
    | Export
    | ReceiveExportedBlueprint Model


update : Msg -> Context -> ( Model, Cmd Msg )
update msg { model, entities } =
    case msg of
        Changed blueprint ->
            ( blueprint, parseBlueprint blueprint )

        Load ->
            ( model, parseBlueprint model )

        Export ->
            ( model, exportBlueprint (encodeBlueprint entities) )

        ReceiveExportedBlueprint blueprint ->
            ( blueprint, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ textarea [ onInput Changed, value model ] []
        , input [ type_ "button", value "Load Blueprint", onClick Load ] []
        , input [ type_ "button", value "Export Blueprint", onClick Export ] []
          -- , input [ type_ "button", value "Clear Entities", onClick ClearEntities ] []
        ]
