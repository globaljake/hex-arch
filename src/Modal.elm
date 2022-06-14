module Modal exposing
    ( Modal
    , Msg
    , Variant(..)
    , close
    , init
    , open
    , subscriptions
    , update
    , view
    )

import Api.HexArch.Data.Thing exposing (Thing)
import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Modal.Auth as Auth
import Modal.EditProfile as EditProfile
import Relay
import Session exposing (Session)



-- STATE


type Modal
    = Hidden
    | Auth Auth.Model
    | EditProfile EditProfile.Model


type Variant
    = AuthModal Auth.Variant
    | EditProfileModal



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
            AuthModal subVariant ->
                Auth.init subVariant
                    |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

            EditProfileModal ->
                EditProfile.init
                    |> Tuple.mapBoth EditProfile (Cmd.map EditProfileMsg)

    else
        ( modal, Cmd.none )



-- INPUT


type Msg
    = GotRelayInternalMsg RelayInternalMsg
    | GotRelayError Decode.Error
    | AuthMsg Auth.Msg
    | EditProfileMsg EditProfile.Msg



-- TRANSITION


update : Session -> Msg -> Modal -> ( Modal, Cmd Msg )
update session msg model =
    case ( msg, model ) of
        ( GotRelayInternalMsg subMsg, _ ) ->
            updateRelayInternalMsg subMsg model

        ( GotRelayError err, _ ) ->
            ( model, Cmd.none )

        ( AuthMsg subMsg, Auth subModel ) ->
            Auth.update subMsg subModel
                |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

        ( EditProfileMsg subMsg, EditProfile subModel ) ->
            EditProfile.update subMsg subModel
                |> Tuple.mapBoth EditProfile (Cmd.map EditProfileMsg)

        _ ->
            ( model, Cmd.none )


updateRelayInternalMsg : RelayInternalMsg -> Modal -> ( Modal, Cmd Msg )
updateRelayInternalMsg msg modal =
    case msg of
        OpenModal variant ->
            initVariant variant modal

        CloseModal ->
            ( Hidden, Cmd.none )



-- OUTPUT


view : Modal -> Html Msg
view modal =
    case modal of
        Auth subModel ->
            Auth.view subModel
                |> viewContent
                |> Html.map AuthMsg

        EditProfile subModel ->
            EditProfile.view subModel
                |> viewContent
                |> Html.map EditProfileMsg

        Hidden ->
            Html.text ""


viewContent : Html msg -> Html msg
viewContent content =
    Html.div [ Attributes.class "flex flex-col space-y-4" ] [ content ]



-- INTERNAL RELAY


type RelayInternalMsg
    = OpenModal Variant
    | CloseModal


internalAdapter : Relay.Adapter
internalAdapter =
    Relay.internal "Modal"


internalMessage : RelayInternalMsg -> Relay.Message
internalMessage msg =
    Relay.message internalAdapter encodeRelayInternalMsg msg


open : Variant -> Cmd msg
open variant =
    Relay.publish (internalMessage (OpenModal variant))


close : Cmd msg
close =
    Relay.publish (internalMessage CloseModal)


internalReceiver : (RelayInternalMsg -> msg) -> Relay.Receiver msg
internalReceiver tagger =
    Relay.receiver internalAdapter (Decode.map tagger decoderRelayInternalMsg)


encodeRelayInternalMsg : RelayInternalMsg -> Encode.Value
encodeRelayInternalMsg input =
    case input of
        OpenModal variant ->
            Encode.object
                [ ( "constructor", Encode.string "OpenModal" )
                , ( "payload", encodeVariant variant )
                ]

        CloseModal ->
            Encode.object [ ( "constructor", Encode.string "CloseModal" ) ]


decoderRelayInternalMsg : Decode.Decoder RelayInternalMsg
decoderRelayInternalMsg =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "OpenModal" ->
                        Decode.map OpenModal (Decode.field "payload" decoderVariant)

                    "CloseModal" ->
                        Decode.succeed CloseModal

                    _ ->
                        Decode.fail ("Type constructor could not be found: " ++ str)
            )


encodeVariant : Variant -> Encode.Value
encodeVariant variant =
    case variant of
        AuthModal subVariant ->
            Encode.object
                [ ( "constructor", Encode.string "AuthModal" )
                , ( "payload", Auth.encodeVariant subVariant )
                ]

        EditProfileModal ->
            Encode.object [ ( "constructor", Encode.string "EditProfileModal" ) ]


decoderVariant : Decode.Decoder Variant
decoderVariant =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "AuthModal" ->
                        Decode.succeed AuthModal
                            |> Decode.required "payload" Auth.decoderVariant

                    "EditProfileModal" ->
                        Decode.succeed EditProfileModal

                    _ ->
                        Decode.fail "Not a type constructor for Modal.Variant"
            )



-- SUBSCRIPTIONS


subscriptions : Modal -> Sub Msg
subscriptions modal =
    Sub.batch
        [ Relay.subscribe GotRelayError
            [ internalReceiver GotRelayInternalMsg
            ]
        ]
