port module ExternalMsg exposing (ExternalMsg, MessageId, extMsg, id, map, send, toSubscription)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode


type MessageId
    = MessageId String


type ExternalMsg msg
    = ExternalMsg MessageId (Decode.Decoder msg)


id : String -> MessageId
id =
    MessageId


send : MessageId -> (a -> Encode.Value) -> a -> Cmd msg
send (MessageId id_) encode payload =
    extSendMessage <|
        Encode.object
            [ ( "messageId", Encode.string id_ )
            , ( "payload", encode payload )
            ]


extMsg : MessageId -> Decode.Decoder a -> (a -> msg) -> ExternalMsg msg
extMsg messageId decoder tagger =
    ExternalMsg messageId (Decode.map tagger decoder)


toSubscription : (Decode.Error -> msg) -> List (List (ExternalMsg msg)) -> Sub msg
toSubscription errorToMsg listReceivers =
    case List.concat listReceivers of
        [] ->
            Sub.none

        list ->
            extMessageReceiver
                (\value ->
                    case Decode.decodeValue (decoderReceiverResult list) value of
                        Ok msg ->
                            msg

                        Err err ->
                            errorToMsg err
                )


decoderReceiverResult : List (ExternalMsg msg) -> Decode.Decoder msg
decoderReceiverResult list =
    let
        matchMessageId decodedId (ExternalMsg (MessageId id_) decoder) acc =
            if (acc == Nothing) && decodedId == id_ then
                Just (ExternalMsg (MessageId id_) decoder)

            else
                acc
    in
    Decode.succeed
        (\decodedId ->
            case List.foldl (matchMessageId decodedId) Nothing list of
                Just (ExternalMsg _ decoder) ->
                    Decode.field "payload" decoder

                Nothing ->
                    Decode.fail ("ExternalMsg.MessageId doesn't match: " ++ decodedId)
        )
        |> Decode.required "messageId" Decode.string
        |> Decode.resolve



-- FUNCTOR


map : (a -> msg) -> ExternalMsg a -> ExternalMsg msg
map f (ExternalMsg messageId decoderMsg) =
    ExternalMsg messageId (Decode.map f decoderMsg)



-- PORTS


port extSendMessage : Encode.Value -> Cmd msg


port extMessageReceiver : (Encode.Value -> msg) -> Sub msg
