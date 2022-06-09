module Port exposing (Event(..), Instruction(..), decoderEvent, decoderInstruction, encodeEvent, encodeInstruction)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



-- EVENT
-- This is used for publishing an event from inside the module for another module outside of it to subscribe  to


type Event a
    = Added a
    | Removed a
    | Cleared


encodeEvent : (a -> Encode.Value) -> Event a -> Encode.Value
encodeEvent encodePayload event =
    case event of
        Added data ->
            Encode.object [ ( "constructor", Encode.string "Added" ), ( "payload", encodePayload data ) ]

        Removed data ->
            Encode.object [ ( "constructor", Encode.string "Removed" ), ( "payload", encodePayload data ) ]

        Cleared ->
            Encode.object [ ( "constructor", Encode.string "Cleared" ) ]


decoderEvent : Decode.Decoder a -> Decode.Decoder (Event a)
decoderEvent decoderPayload =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Added" ->
                        Decode.field "payload" decoderPayload
                            |> Decode.map Added

                    "Removed" ->
                        Decode.field "payload" decoderPayload
                            |> Decode.map Removed

                    "Cleared" ->
                        Decode.succeed Cleared

                    _ ->
                        Decode.fail ("Type constructor could not be found for Event: " ++ str)
            )



-- INSTRUCTION
-- This is used for sending input into a module from outside of a module. usually used for the Session and other high level services


type Instruction a
    = Add a
    | Remove a
    | Clear


encodeInstruction : (a -> Encode.Value) -> Instruction a -> Encode.Value
encodeInstruction encodePayload instruction =
    case instruction of
        Add data ->
            Encode.object [ ( "constructor", Encode.string "Add" ), ( "payload", encodePayload data ) ]

        Remove data ->
            Encode.object [ ( "constructor", Encode.string "Remove" ), ( "payload", encodePayload data ) ]

        Clear ->
            Encode.object [ ( "constructor", Encode.string "Clear" ) ]


decoderInstruction : Decode.Decoder a -> Decode.Decoder (Instruction a)
decoderInstruction decoderPayload =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Add" ->
                        Decode.field "payload" decoderPayload
                            |> Decode.map Add

                    "Remove" ->
                        Decode.field "payload" decoderPayload
                            |> Decode.map Remove

                    "Clear" ->
                        Decode.succeed Clear

                    _ ->
                        Decode.fail ("Type constructor could not be found for Instruction: " ++ str)
            )
