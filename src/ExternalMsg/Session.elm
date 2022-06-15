module ExternalMsg.Session exposing (AskMsg(..), InformMsg(..), askReceiver, clear, inform, informReceiver, updateViewer)

import ExternalMsg
import Json.Decode as Decode
import Json.Encode as Encode
import Viewer exposing (Viewer)



-- PRIMARY


type AskMsg
    = UpdateViewer Viewer
    | Clear


encodeAsk : AskMsg -> Encode.Value
encodeAsk msg =
    case msg of
        UpdateViewer viewer ->
            Encode.object
                [ ( "constructor", Encode.string "UpdateViewer" )
                , ( "payload", Viewer.encode viewer )
                ]

        Clear ->
            Encode.object [ ( "constructor", Encode.string "Clear" ) ]


decoderAsk : Decode.Decoder AskMsg
decoderAsk =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "UpdateViewer" ->
                        Decode.map UpdateViewer (Decode.field "payload" Viewer.decoder)

                    "Clear" ->
                        Decode.succeed Clear

                    _ ->
                        Decode.fail ("Type constructor could not be found: " ++ str)
            )


messageIdAsk : ExternalMsg.MessageId
messageIdAsk =
    ExternalMsg.id "Session.Ask"


updateViewer : Viewer -> Cmd msg
updateViewer viewer =
    ExternalMsg.send messageIdAsk encodeAsk (UpdateViewer viewer)


clear : Cmd msg
clear =
    ExternalMsg.send messageIdAsk encodeAsk Clear


askReceiver : (AskMsg -> msg) -> ExternalMsg.Receiver msg
askReceiver tagger =
    ExternalMsg.receiver messageIdAsk decoderAsk tagger



-- SECONDARY


type InformMsg
    = Authenticated
    | SessionCleared


encodeInform : InformMsg -> Encode.Value
encodeInform input =
    case input of
        Authenticated ->
            Encode.object [ ( "constructor", Encode.string "Authenticated" ) ]

        SessionCleared ->
            Encode.object [ ( "constructor", Encode.string "SessionCleared" ) ]


decodeInform : Decode.Decoder InformMsg
decodeInform =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Authenticated" ->
                        Decode.succeed Authenticated

                    "SessionCleared" ->
                        Decode.succeed SessionCleared

                    _ ->
                        Decode.fail ("Type constructor could not be found: " ++ str)
            )


messageIdInform : ExternalMsg.MessageId
messageIdInform =
    ExternalMsg.id "Session.Inform"


inform : InformMsg -> Cmd msg
inform informMsg =
    ExternalMsg.send messageIdInform encodeInform informMsg


informReceiver : (InformMsg -> msg) -> ExternalMsg.Receiver msg
informReceiver tagger =
    ExternalMsg.receiver messageIdInform decodeInform tagger
