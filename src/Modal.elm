module Modal exposing
    ( Modal
    , Msg
    , extMsgs
    , init
    , subscriptions
    , update
    , view
    )

import ExternalMsg exposing (ExternalMsg)
import ExternalMsg.ModalAsk as ModalAsk
import Html exposing (Html)
import Html.Attributes as Attributes
import Modal.EditProfile as EditProfile
import Modal.SignIn as SignIn
import Modal.Variant as ModalVariant exposing (Variant)
import Session exposing (Session)



-- STATE


type Modal
    = Hidden
    | SignIn SignIn.Model
    | EditProfile EditProfile.Model



-- INITIAL STATE


init : Maybe Variant -> ( Modal, Cmd Msg )
init maybeVariant =
    case maybeVariant of
        Just variant ->
            initVariant variant Hidden

        Nothing ->
            ( Hidden, Cmd.none )


initVariant : Variant -> Modal -> ( Modal, Cmd Msg )
initVariant variant modal =
    if modal == Hidden then
        case variant of
            ModalVariant.SignInModal _ ->
                SignIn.init
                    |> Tuple.mapBoth SignIn (Cmd.map SignInMsg)

            ModalVariant.EditProfileModal _ ->
                EditProfile.init
                    |> Tuple.mapBoth EditProfile (Cmd.map EditProfileMsg)

    else
        ( modal, Cmd.none )



-- INPUT


type Msg
    = GotModalAskExtMsg ModalAsk.ExtMsg
    | SignInMsg SignIn.Msg
    | EditProfileMsg EditProfile.Msg



-- TRANSITION


update : Session -> Msg -> Modal -> ( Modal, Cmd Msg )
update session msg model =
    case ( msg, model ) of
        ( GotModalAskExtMsg subMsg, _ ) ->
            updateModalAskExtMsg subMsg model

        ( SignInMsg subMsg, SignIn subModel ) ->
            SignIn.update subMsg subModel
                |> Tuple.mapBoth SignIn (Cmd.map SignInMsg)

        ( EditProfileMsg subMsg, EditProfile subModel ) ->
            EditProfile.update subMsg subModel
                |> Tuple.mapBoth EditProfile (Cmd.map EditProfileMsg)

        _ ->
            ( model, Cmd.none )


updateModalAskExtMsg : ModalAsk.ExtMsg -> Modal -> ( Modal, Cmd Msg )
updateModalAskExtMsg msg modal =
    case msg of
        ModalAsk.ToOpen variant ->
            initVariant variant modal

        ModalAsk.ToClose ->
            ( Hidden, Cmd.none )



-- OUTPUT


view : Modal -> Html Msg
view modal =
    case modal of
        SignIn subModel ->
            SignIn.view subModel
                |> viewContent
                |> Html.map SignInMsg

        EditProfile subModel ->
            EditProfile.view subModel
                |> viewContent
                |> Html.map EditProfileMsg

        Hidden ->
            Html.text ""


viewContent : Html msg -> Html msg
viewContent content =
    Html.div [ Attributes.class "flex flex-col space-y-4" ] [ content ]



-- SUBSCRIPTIONS


subscriptions : Modal -> Sub Msg
subscriptions modal =
    Sub.none


extMsgs : List (ExternalMsg Msg)
extMsgs =
    List.concat
        [ [ ModalAsk.extMsg GotModalAskExtMsg ]
        , EditProfile.extMsgs
            |> List.map (ExternalMsg.map EditProfileMsg)
        ]
