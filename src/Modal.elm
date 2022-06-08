port module Modal exposing (Config(..), Modal, Msg, close, empty, init, open, subscriptions, update, view)

import Application.Instruction as Instruction exposing (Instruction)
import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Modal.Auth as Auth
import Modal.BuyCoins as BuyCoins
import Modal.EncoderSetup as EncoderSetup
import Session exposing (Session)



-- STATE


type Modal
    = Hidden
    | Auth Auth.Model
    | BuyCoins BuyCoins.Model
    | EncoderSetup EncoderSetup.Model


type Config
    = AuthConfig Auth.AuthType
    | BuyCoinsConfig ()
    | EncoderSetupConfig ()



-- INITIAL STATE


empty : Modal
empty =
    Hidden


init : Maybe Config -> ( Modal, Cmd Msg )
init maybeConfig =
    case maybeConfig of
        Nothing ->
            ( Hidden, Cmd.none )

        Just (AuthConfig config) ->
            Auth.init config
                |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

        Just (BuyCoinsConfig config) ->
            BuyCoins.init config
                |> Tuple.mapBoth BuyCoins (Cmd.map BuyCoinsMsg)

        Just (EncoderSetupConfig config) ->
            EncoderSetup.init config
                |> Tuple.mapBoth EncoderSetup (Cmd.map EncoderSetupMsg)



-- INPUT


type Msg
    = GotInstruction (Result Decode.Error (Instruction Config))
    | AuthMsg Auth.Msg
    | BuyCoinsMsg BuyCoins.Msg
    | EncoderSetupMsg EncoderSetup.Msg


type MsgRequest
    = InitAuth ()
    | InitBuyCoins ()
    | InitEncoderSetup ()


type MsgResponse
    = GotSomething



-- Need to think of name for anyone calling a command that the child will listen to
-- Currently named instruction ... but this is the api for the microservice essentially. Request????
-- Need to think of the name for the messages that a module outside of this one will listen to
-- this is a replacement for ExtMsg to be more like hexagonal architecture
-- TRANSITION


update : Session -> Msg -> Modal -> ( Modal, Cmd Msg )
update session msg model =
    case ( msg, model ) of
        ( GotInstruction (Ok instruction), Hidden ) ->
            updateInstruction instruction model

        ( AuthMsg subMsg, Auth subModel ) ->
            Auth.update subMsg subModel
                |> Tuple.mapBoth Auth (Cmd.map AuthMsg)

        ( BuyCoinsMsg subMsg, BuyCoins subModel ) ->
            BuyCoins.update subMsg subModel
                |> Tuple.mapBoth BuyCoins (Cmd.map BuyCoinsMsg)

        ( EncoderSetupMsg subMsg, EncoderSetup subModel ) ->
            EncoderSetup.update subMsg subModel
                |> Tuple.mapBoth EncoderSetup (Cmd.map EncoderSetupMsg)

        _ ->
            ( model, Cmd.none )


updateInstruction : Instruction Config -> Modal -> ( Modal, Cmd Msg )
updateInstruction instruction model =
    case instruction of
        Instruction.Add config ->
            if model == Hidden then
                init (Just config)

            else
                ( model, Cmd.none )

        Instruction.Clear ->
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

        BuyCoins subModel ->
            BuyCoins.view subModel
                |> viewContent
                |> Html.map BuyCoinsMsg

        EncoderSetup subModel ->
            EncoderSetup.view subModel
                |> viewContent
                |> Html.map EncoderSetupMsg

        Hidden ->
            Html.text ""


viewContent : Html msg -> Html msg
viewContent content =
    Html.div [ Attributes.class "flex flex-col space-y-4" ] [ content ]



-- PORTS


port modalSendInstruction : Encode.Value -> Cmd msg


port modalReceiveInstruction : (Encode.Value -> msg) -> Sub msg


open : Config -> Cmd msg
open config =
    modalSendInstruction (Instruction.encode encodeConfig (Instruction.Add config))


close : Cmd msg
close =
    modalSendInstruction (Instruction.encode encodeConfig Instruction.Clear)


subscriptions : Sub Msg
subscriptions =
    modalReceiveInstruction (GotInstruction << Decode.decodeValue (Instruction.decoder decoderConfig))



-- ADAPTERS


encodeConfig : Config -> Encode.Value
encodeConfig config =
    case config of
        AuthConfig subConfig ->
            Encode.object
                [ ( "constructor", Encode.string "AuthConfig" )
                , ( "payload", Auth.encodeAuthType subConfig )
                ]

        BuyCoinsConfig () ->
            Encode.object [ ( "constructor", Encode.string "BuyCoinsConfig" ) ]

        EncoderSetupConfig () ->
            Encode.object [ ( "constructor", Encode.string "EncoderSetupConfig" ) ]


decoderConfig : Decode.Decoder Config
decoderConfig =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "AuthConfig" ->
                        Decode.succeed AuthConfig
                            |> Decode.required "payload" Auth.decoderAuthType

                    "BuyCoinsConfig" ->
                        Decode.succeed (BuyCoinsConfig ())

                    "EncoderSetupConfig" ->
                        Decode.succeed (EncoderSetupConfig ())

                    _ ->
                        Decode.fail "Not a type constructor for Modal.ModalConfig"
            )
