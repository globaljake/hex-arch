module ExternalMsg.ModalAsk exposing (ExtMsg(..), close, extMsg, open)

import ExternalMsg exposing (ExternalMsg)
import Json.Decode as Decode
import Json.Encode as Encode
import ModalRoute as ModalRoute exposing (ModalRoute)



-- TYPE


type ExtMsg
    = ToOpen ModalRoute
    | ToClose



-- KEY


key : ExternalMsg.Key
key =
    ExternalMsg.key "ModalAsk"



-- SEND


open : ModalRoute -> Cmd msg
open modalRoute =
    ExternalMsg.send key encode (ToOpen modalRoute)


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
        ToOpen modalRoute ->
            Encode.object
                [ ( "constructor", Encode.string "ToOpen" )
                , ( "payload", ModalRoute.encode modalRoute )
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
                        Decode.map ToOpen (Decode.field "payload" ModalRoute.decoder)

                    "ToClose" ->
                        Decode.succeed ToClose

                    _ ->
                        Decode.fail ("Type constructor could not be found: " ++ str)
            )
