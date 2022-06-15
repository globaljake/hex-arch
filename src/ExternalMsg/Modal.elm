module ExternalMsg.Modal exposing (AskMsg(..), close, open, receiver)

import ExternalMsg
import Json.Decode as Decode
import Json.Encode as Encode
import Modal.Variant as ModalVariant exposing (Variant)


type AskMsg
    = ToOpen Variant
    | ToClose


encode : AskMsg -> Encode.Value
encode input =
    case input of
        ToOpen variant ->
            Encode.object
                [ ( "constructor", Encode.string "ToOpen" )
                , ( "payload", ModalVariant.encode variant )
                ]

        ToClose ->
            Encode.object [ ( "constructor", Encode.string "ToClose" ) ]


decoder : Decode.Decoder AskMsg
decoder =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "ToOpen" ->
                        Decode.map ToOpen (Decode.field "payload" ModalVariant.decoder)

                    "ToClose" ->
                        Decode.succeed ToClose

                    _ ->
                        Decode.fail ("Type constructor could not be found: " ++ str)
            )


messageId : ExternalMsg.MessageId
messageId =
    ExternalMsg.id "Modal"


open : Variant -> Cmd msg
open variant =
    ExternalMsg.send messageId encode (ToOpen variant)


close : Cmd msg
close =
    ExternalMsg.send messageId encode ToClose


receiver : (AskMsg -> msg) -> ExternalMsg.Receiver msg
receiver tagger =
    ExternalMsg.receiver messageId decoder tagger
