module Entity.Picker exposing (..)

import Html exposing (Html, div, img)
import Html.Attributes exposing (src, alt)
import Html.Events exposing (onClick)
import Entity exposing (EntityName(..))
import Entity.Image
import Html.CssHelpers
import ToolboxStyles exposing (Ids(..), Classes(..))


-- MODEL


type alias Model =
    { currentEntity : EntityName
    , currentGroup : Group
    }


init : Model
init =
    { currentEntity = TransportBelt
    , currentGroup = logistics
    }


type alias Row =
    List EntityName


type alias Group =
    { entities : List Row
    , type_ : GroupType
    }


type GroupType
    = Logistics
    | Production


logistics : Group
logistics =
    { entities =
        [ [ WoodenChest, IronChest, SteelChest ]
        , [ TransportBelt, FastTransportBelt, ExpressTransportBelt ]
        ]
    , type_ = Logistics
    }


production : Group
production =
    { entities =
        [ [ AssemblingMachine1, AssemblingMachine2, AssemblingMachine3 ]
        ]
    , type_ = Production
    }


allGroups : List Group
allGroups =
    [ logistics, production ]



-- UPDATE


type Msg
    = SelectEntity EntityName
    | SelectGroup Group


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectEntity entity ->
            ( { model | currentEntity = entity }, Cmd.none )

        SelectGroup group ->
            ( { model | currentGroup = group }, Cmd.none )



-- CSS


{ id, class, classList } =
    Html.CssHelpers.withNamespace "toolbox"



-- VIEW


view : Model -> Html Msg
view model =
    div [ id [ Container ] ]
        [ div [ id [ ToolGroupContainer ] ]
            [ div [ id [ ToolboxStyles.ToolGroup ] ] (List.map (tabView model) allGroups)
            , groupView model
            ]
        ]


tabView : Model -> Group -> Html Msg
tabView model group =
    let
        classes =
            if group == model.currentGroup then
                class [ ToolGroupItem, SelectedToolGroupItem ]
            else
                class [ ToolGroupItem ]
    in
        div [ classes, onClick (SelectGroup group) ] [ img [ src (imageForGroup group) ] [] ]


groupView : Model -> Html Msg
groupView model =
    div [ id [ ToolboxItems ] ] (List.map (rowView model) model.currentGroup.entities)


rowView : Model -> Row -> Html Msg
rowView model row =
    div [ class [ ToolboxStyles.ToolRow ] ] (List.map (selectableEntityView model) row)


selectableEntityView : Model -> EntityName -> Html Msg
selectableEntityView model entity =
    div [ class [ ToolboxStyles.Tool ], onClick (SelectEntity entity) ]
        [ enitityView model entity ]


enitityView : Model -> EntityName -> Html msg
enitityView model entity =
    let
        classes =
            if model.currentEntity == entity then
                [ Button, SelectedButton ]
            else
                [ Button ]
    in
        div [ class classes ]
            [ img [ src (Entity.Image.icon entity), alt (Entity.readableName entity) ] []
            ]



-- VIEW HELPERS


imageForGroup : Group -> String
imageForGroup group =
    case group.type_ of
        Logistics ->
            "assets/images/item-group/logistics.png"

        Production ->
            "assets/images/item-group/production.png"
