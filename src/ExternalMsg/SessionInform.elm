module ExternalMsg.SessionInform exposing (ExtMsg(..), extMsg, send)

import ExternalMsg exposing (ExternalMsg)
import Json.Decode as Decode
import Json.Encode as Encode



-- TYPE


type ExtMsg
    = Authenticated
    | SessionCleared



-- MESSAGE ID


key : ExternalMsg.Key
key =
    ExternalMsg.key "Session.Inform"



-- SEND


send : ExtMsg -> Cmd msg
send msg =
    ExternalMsg.send key encode msg



-- RECEIVE


extMsg : (ExtMsg -> msg) -> ExternalMsg msg
extMsg tagger =
    ExternalMsg.extMsg key decoder tagger



-- ENCODE / DECODE


encode : ExtMsg -> Encode.Value
encode msg =
    case msg of
        Authenticated ->
            Encode.object [ ( "constructor", Encode.string "Authenticated" ) ]

        SessionCleared ->
            Encode.object [ ( "constructor", Encode.string "SessionCleared" ) ]


decoder : Decode.Decoder ExtMsg
decoder =
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
