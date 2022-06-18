module ExternalMsg.ModalAsk exposing (ExtMsg(..), close, extMsg, open)

import ExternalMsg exposing (ExternalMsg)
import Json.Decode as Decode
import Json.Encode as Encode
import Modal.Variant as ModalVariant exposing (Variant)



-- TYPE


type ExtMsg
    = ToOpen Variant
    | ToClose



-- KEY


key : ExternalMsg.Key
key =
    ExternalMsg.key "ModalAsk"



-- SEND


open : Variant -> Cmd msg
open variant =
    ExternalMsg.send key encode (ToOpen variant)


close : Cmd msg
close =
    ExternalMsg.send key encode ToClose



-- RECEIVE


extMsg : (ExtMsg -> msg) -> ExternalMsg msg
extMsg tagger =
    ExternalMsg.extMsg key decoder tagger



-- ENCODE / DECODE


encode : ExtMsg -> Encode.Value
encode msg =
    case msg of
        ToOpen variant ->
            Encode.object
                [ ( "constructor", Encode.string "ToOpen" )
                , ( "payload", ModalVariant.encode variant )
                ]

        ToClose ->
            Encode.object [ ( "constructor", Encode.string "ToClose" ) ]


decoder : Decode.Decoder ExtMsg
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
