module ModuleRequest exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode


encode : String -> Encode.Value -> Encode.Value
encode constructor payload =
    Encode.object [ ( "constructor", Encode.string constructor ), ( "payload", payload ) ]


decoder : (( String, String ) -> Decode.Decoder a) -> Decode.Decoder a
decoder toDecoder =
    Decode.succeed Tuple.pair
        |> Decode.required "constructor" Decode.string
        |> Decode.hardcoded "payload"
        |> Decode.andThen toDecoder


failMessage : String -> String
failMessage constructor =
    "Not a type constructor for Module Request " ++ constructor
