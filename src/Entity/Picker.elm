module Entity.Picker exposing (..)

import Css exposing (..)
import Entity exposing (EntityName(..))
import Entity.Image
import Html.Styled exposing (Html, div, img)
import Html.Styled.Attributes exposing (alt, css, src, styled)
import Html.Styled.Events exposing (onClick)


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



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ css
            [ border2 (px 1) solid
            , padding (px 8)
            , displayFlex
            ]
        ]
        [ div
            [ css
                [ backgroundColor (hex "#888")
                , padding (px 4)
                , margin2 (px 4) zero
                ]
            ]
            [ div [ css [ displayFlex ] ] (List.map (tabView model) allGroups)
            , groupView model
            ]
        ]


tabView : Model -> Group -> Html Msg
tabView model group =
    let
        image =
            styled img
                [ width (px 68), height (px 68), padding (px 2) ]

        itemStyles =
            Css.batch
                [ backgroundImage (url "/assets/images/button-72.png")
                , backgroundPosition2 (px 0) (px -2)
                , margin2 zero (px 2)
                , width (px 72)
                , height (px 72)
                ]

        selectedItemStyles =
            Css.batch [ backgroundPosition2 (px 74) (px -2) ]

        classes =
            if group == model.currentGroup then
                css [ itemStyles, selectedItemStyles ]
            else
                css [ itemStyles ]
    in
    div [ classes, onClick (SelectGroup group) ] [ image [ src (imageForGroup group) ] [] ]


groupView : Model -> Html Msg
groupView model =
    div
        [ css
            [ displayFlex
            , flexWrap wrap
            , textAlign center
            , margin2 (px 8) zero
            , flexDirection column
            ]
        ]
        (List.map (rowView model) model.currentGroup.entities)


rowView : Model -> Row -> Html Msg
rowView model row =
    div [ css [ displayFlex ] ] (List.map (selectableEntityView model) row)


selectableEntityView : Model -> EntityName -> Html Msg
selectableEntityView model entity =
    div [ css [ flex2 zero zero ], onClick (SelectEntity entity) ]
        [ enitityView model entity ]


enitityView : Model -> EntityName -> Html msg
enitityView model entity =
    let
        image =
            styled img
                [ width (px 30)
                , height (px 30)
                , margin2 (px 4) (px 3)
                ]

        buttonStyles =
            Css.batch
                [ width (px 36)
                , height (px 36)
                , textAlign center
                , verticalAlign center
                , backgroundImage (url "/assets/images/button-36.png")
                , backgroundPosition2 (px -2) zero
                ]

        selectedButtonStyles =
            Css.batch [ backgroundPosition2 (px -40) (px 1) ]

        classes =
            if model.currentEntity == entity then
                [ buttonStyles, selectedButtonStyles ]
            else
                [ buttonStyles ]
    in
    div [ css classes ]
        [ image [ src (Entity.Image.icon entity), alt (Entity.readableName entity) ] []
        ]



-- VIEW HELPERS


imageForGroup : Group -> String
imageForGroup group =
    case group.type_ of
        Logistics ->
            "assets/images/item-group/logistics.png"

        Production ->
            "assets/images/item-group/production.png"
