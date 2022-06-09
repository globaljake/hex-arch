port module Modal exposing (Modal, Msg, Variant(..), close, init, open, subscriptions, update, view)

import Api.HexArch.Data.Thing exposing (Thing)
import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Modal.Auth as Auth
import Modal.EditProfile as EditProfile
import Port
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
        Just (AuthModal subVariant) ->
            Auth.init subVariant
                |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

        Just EditProfileModal ->
            EditProfile.init
                |> Tuple.mapBoth EditProfile (Cmd.map EditProfileMsg)

        Nothing ->
            ( Hidden, Cmd.none )



-- INPUT


type Msg
    = GotInstruction (Result Decode.Error (Port.Instruction Variant))
    | AuthMsg Auth.Msg
    | EditProfileMsg EditProfile.Msg



-- TRANSITION


update : Session -> Msg -> Modal -> ( Modal, Cmd Msg )
update session msg model =
    case ( msg, model ) of
        ( GotInstruction (Ok instruction), _ ) ->
            updateInstruction instruction model

        ( AuthMsg subMsg, Auth subModel ) ->
            Auth.update subMsg subModel
                |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

        ( EditProfileMsg subMsg, EditProfile subModel ) ->
            EditProfile.update close subMsg subModel
                |> Tuple.mapBoth EditProfile (Cmd.map EditProfileMsg)

        _ ->
            ( model, Cmd.none )


updateInstruction : Port.Instruction Variant -> Modal -> ( Modal, Cmd Msg )
updateInstruction instruction model =
    case ( instruction, model ) of
        ( Port.Add variant, Hidden ) ->
            init (Just variant)

        ( Port.Clear, _ ) ->
            ( Hidden, Cmd.none )

        _ ->
            ( model, Cmd.none )



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



-- INSTRUCTIONS


port modalSendInstruction : Encode.Value -> Cmd msg


open : Variant -> Cmd msg
open variant =
    modalSendInstruction (Port.encodeInstruction encodeVariant (Port.Add variant))


close : Cmd msg
close =
    modalSendInstruction (Port.encodeInstruction (\_ -> Encode.null) Port.Clear)


port modalReceiveInstruction : (Encode.Value -> msg) -> Sub msg


instructions : (Result Decode.Error (Port.Instruction Variant) -> Msg) -> Sub Msg
instructions tagger =
    modalReceiveInstruction
        (tagger << Decode.decodeValue (Port.decoderInstruction decoderVariant))


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


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ instructions GotInstruction
        ]
