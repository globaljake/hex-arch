module ExternalMsg.ThingForm exposing (InformMsg(..), inform, receiver)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import ExternalMsg
import Json.Decode as Decode
import Json.Encode as Encode


type InformMsg
    = GotThing Thing


encode : InformMsg -> Encode.Value
encode msg =
    case msg of
        GotThing thing ->
            Encode.object
                [ ( "constructor", Encode.string "GotThing" )
                , ( "payload", Thing.encode thing )
                ]


decoder : Decode.Decoder InformMsg
decoder =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "GotThing" ->
                        Decode.map GotThing (Decode.field "payload" Thing.decoder)

                    _ ->
                        Decode.fail ("Type constructor could not be found: " ++ str)
            )


messageId : ExternalMsg.MessageId
messageId =
    ExternalMsg.id "ThingForm"


inform : Thing -> Cmd msg
inform thing =
    ExternalMsg.send messageId encode (GotThing thing)


receiver : (InformMsg -> msg) -> ExternalMsg.Receiver msg
receiver tagger =
    ExternalMsg.receiver messageId decoder tagger
