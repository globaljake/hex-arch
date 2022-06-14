port module Relay exposing (Adapter, Message, Receiver, external, internal, map, message, publish, receiver, subscribe)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode


type Adapter
    = Primary String
    | Secondary String


type Message
    = Message Encode.Value


type Receiver msg
    = Receiver Adapter (Decode.Decoder msg)


internal : String -> Adapter
internal name =
    Primary name


external : String -> Adapter
external name =
    Secondary name


adapterToString : Adapter -> String
adapterToString adapter =
    case adapter of
        Primary name ->
            name ++ ".Adapter.Primary"

        Secondary name ->
            name ++ ".Adapter.Secondary"


message : Adapter -> (a -> Encode.Value) -> a -> Message
message adapter encodeMsg msg =
    Message
        (Encode.object
            [ ( "adapter", Encode.string (adapterToString adapter) )
            , ( "msg", encodeMsg msg )
            ]
        )


receiver : Adapter -> Decode.Decoder msg -> Receiver msg
receiver =
    Receiver


map : (a -> b) -> Receiver a -> Receiver b
map f (Receiver adapter decoderMsg) =
    Receiver adapter (Decode.map f decoderMsg)



-- PORTS


publish : Message -> Cmd msg
publish (Message value) =
    relaySendMessage value


subscribe : (Decode.Error -> msg) -> List (Receiver msg) -> Sub msg
subscribe errorToMsg listReceivers =
    case listReceivers of
        [] ->
            Sub.none

        list ->
            relayMessageReceiver
                (\value ->
                    case Decode.decodeValue (decoderReceiverResult list) value of
                        Ok msg ->
                            msg

                        Err err ->
                            errorToMsg err
                )


decoderReceiverResult : List (Receiver msg) -> Decode.Decoder msg
decoderReceiverResult list =
    let
        matchAdapter adapterName (Receiver adapter decoderMsg) acc =
            if (acc == Nothing) && adapterName == adapterToString adapter then
                Just (Receiver adapter decoderMsg)

            else
                acc
    in
    Decode.succeed
        (\adapterName ->
            case List.foldl (matchAdapter adapterName) Nothing list of
                Just (Receiver _ decoderMsg) ->
                    Decode.field "msg" decoderMsg

                Nothing ->
                    Decode.fail ("Relay.Adapter doesn't match: " ++ adapterName)
        )
        |> Decode.required "adapter" Decode.string
        |> Decode.resolve



-- ADAPTERS


port relaySendMessage : Encode.Value -> Cmd msg


port relayMessageReceiver : (Encode.Value -> msg) -> Sub msg
