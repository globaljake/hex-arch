module Modal exposing (Modal, Msg, extMsgs, init, subscriptions, update, view)

import ExternalMsg exposing (ExternalMsg)
import ExternalMsg.ModalAsk as ModalAsk
import Html exposing (Html)
import Html.Attributes as Attributes
import Modal.EditProfile as EditProfile
import Modal.SignIn as SignIn
import ModalRoute exposing (ModalRoute)
import Session exposing (Session)



-- STATE


type Modal
    = Hidden
    | SignIn SignIn.Model
    | EditProfile EditProfile.Model



-- INITIAL STATE


init : Maybe ModalRoute -> ( Modal, Cmd Msg )
init maybeModalRoute =
    case maybeModalRoute of
        Just modalRoute ->
            initModalRoute modalRoute Hidden

        Nothing ->
            ( Hidden, Cmd.none )


initModalRoute : ModalRoute -> Modal -> ( Modal, Cmd Msg )
initModalRoute modalRoute modal =
    if modal == Hidden then
        case modalRoute of
            ModalRoute.SignInModal _ ->
                SignIn.init
                    |> Tuple.mapBoth SignIn (Cmd.map SignInMsg)

            ModalRoute.EditProfileModal _ ->
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
        ModalAsk.ToOpen modalRoute ->
            initModalRoute modalRoute modal

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


extMsgs : Modal -> List (ExternalMsg Msg)
extMsgs modal =
    List.concat
        [ [ ModalAsk.extMsg GotModalAskExtMsg ]
        , EditProfile.extMsgs
            |> List.map (ExternalMsg.map EditProfileMsg)
        ]
