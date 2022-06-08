module Application.Instruction exposing (Instruction(..), decoder, encode)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



-- BOUNDED CONTEXT
-- TYPE


type Instruction a
    = Add a
    | Remove a
    | Clear



-- ADAPTERS


encode : (a -> Encode.Value) -> Instruction a -> Encode.Value
encode encodePayload control =
    case control of
        Add data ->
            Encode.object [ ( "constructor", Encode.string "Add" ), ( "payload", encodePayload data ) ]

        Remove data ->
            Encode.object [ ( "constructor", Encode.string "Remove" ), ( "payload", encodePayload data ) ]

        Clear ->
            Encode.object [ ( "constructor", Encode.string "Clear" ) ]


decoder : Decode.Decoder a -> Decode.Decoder (Instruction a)
decoder decoderPayload =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "Add" ->
                        Decode.field "payload" decoderPayload
                            |> Decode.map Add

                    "Remove" ->
                        Decode.field "payload" decoderPayload
                            |> Decode.map Remove

                    "Clear" ->
                        Decode.succeed Clear

                    _ ->
                        Decode.fail "Not a type constructor for Application.Instruction"
            )
