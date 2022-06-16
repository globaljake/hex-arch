port module ExternalMsg exposing (ExternalMsg, Key, extMsg, key, map, send, toSubscription)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode


type Key
    = Key String


type ExternalMsg msg
    = ExternalMsg Key (Decode.Decoder msg)


key : String -> Key
key =
    Key


send : Key -> (a -> Encode.Value) -> a -> Cmd msg
send (Key id_) encode payload =
    extSendMessage <|
        Encode.object
            [ ( "key", Encode.string id_ )
            , ( "payload", encode payload )
            ]


extMsg : Key -> Decode.Decoder a -> (a -> msg) -> ExternalMsg msg
extMsg key_ decoder tagger =
    ExternalMsg key_ (Decode.map tagger decoder)


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
        matchKey decodedKey (ExternalMsg (Key key_) decoder) acc =
            if (acc == Nothing) && decodedKey == key_ then
                Just (ExternalMsg (Key key_) decoder)

            else
                acc
    in
    Decode.succeed
        (\decodedKey ->
            case List.foldl (matchKey decodedKey) Nothing list of
                Just (ExternalMsg _ decoder) ->
                    Decode.field "payload" decoder

                Nothing ->
                    Decode.fail ("ExternalMsg.Key doesn't match: " ++ decodedKey)
        )
        |> Decode.required "key" Decode.string
        |> Decode.resolve



-- FUNCTOR


map : (a -> msg) -> ExternalMsg a -> ExternalMsg msg
map f (ExternalMsg key_ decoderMsg) =
    ExternalMsg key_ (Decode.map f decoderMsg)



-- PORTS


port extSendMessage : Encode.Value -> Cmd msg


port extMessageReceiver : (Encode.Value -> msg) -> Sub msg
