module ExternalMsg.SessionAsk exposing (ExtMsg(..), clear, extMsg, updateViewer)

import ExternalMsg exposing (ExternalMsg)
import Json.Decode as Decode
import Json.Encode as Encode
import Viewer exposing (Viewer)



-- TYPE


type ExtMsg
    = UpdateViewer Viewer
    | Clear



-- KEY


key : ExternalMsg.Key
key =
    ExternalMsg.key "SessionAsk"



-- SEND


updateViewer : Viewer -> Cmd msg
updateViewer viewer =
    ExternalMsg.send key encode (UpdateViewer viewer)


clear : Cmd msg
clear =
    ExternalMsg.send key encode Clear



-- RECEIVE


extMsg : (ExtMsg -> msg) -> ExternalMsg msg
extMsg tagger =
    ExternalMsg.extMsg key decoder tagger



-- ENCODE / DECODE


encode : ExtMsg -> Encode.Value
encode msg =
    case msg of
        UpdateViewer viewer ->
            Encode.object
                [ ( "constructor", Encode.string "UpdateViewer" )
                , ( "payload", Viewer.encode viewer )
                ]

        Clear ->
            Encode.object [ ( "constructor", Encode.string "Clear" ) ]


decoder : Decode.Decoder ExtMsg
decoder =
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
