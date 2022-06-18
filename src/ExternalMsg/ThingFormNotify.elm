module ExternalMsg.ThingFormNotify exposing (ExtMsg(..), extMsg, send)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import ExternalMsg
import Json.Decode as Decode
import Json.Encode as Encode



-- TYPE


type ExtMsg
    = GotThing Thing



-- KEY


key : ExternalMsg.Key
key =
    ExternalMsg.key "ThingFormNotify"



-- SEND


send : Thing -> Cmd msg
send thing =
    ExternalMsg.send key encode (GotThing thing)



-- RECEIVE


extMsg : (ExtMsg -> msg) -> ExternalMsg.ExternalMsg msg
extMsg tagger =
    ExternalMsg.extMsg key decoder tagger



-- ENCODE / DECODE


encode : ExtMsg -> Encode.Value
encode msg =
    case msg of
        GotThing thing ->
            Encode.object
                [ ( "constructor", Encode.string "GotThing" )
                , ( "payload", Thing.encode thing )
                ]


decoder : Decode.Decoder ExtMsg
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
