port module ExternalMsg exposing (ExternalMsg, Key, extMsg, key, map, send, toSubscription)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



-- TYPES


type Key
    = Key String


type ExternalMsg msg
    = ExternalMsg Key (Decode.Decoder msg)



-- KEY


key : String -> Key
key =
    Key



-- SEND


send : Key -> (a -> Encode.Value) -> a -> Cmd msg
send (Key id_) encode payload =
    extSendMessage <|
        Encode.object
            [ ( "key", Encode.string id_ )
            , ( "payload", encode payload )
            ]



-- RECEIVE


extMsg : Key -> Decode.Decoder a -> (a -> msg) -> ExternalMsg msg
extMsg key_ decoder tagger =
    ExternalMsg key_ (Decode.map tagger decoder)



-- FUNCTOR


map : (a -> msg) -> ExternalMsg a -> ExternalMsg msg
map f (ExternalMsg key_ decoderMsg) =
    ExternalMsg key_ (Decode.map f decoderMsg)



-- SUBSCRIPTION


port extSendMessage : Encode.Value -> Cmd msg


port extMessageReceiver : (Encode.Value -> msg) -> Sub msg


toSubscription : (Result Decode.Error (List msg) -> msg) -> List (ExternalMsg msg) -> Sub msg
toSubscription toBatchedMsg listExtMsgs =
    case listExtMsgs of
        [] ->
            Sub.none

        extMsgs ->
            extMessageReceiver
                (\value ->
                    case Decode.decodeValue (decoderMsgsByKey extMsgs) value of
                        Err err ->
                            toBatchedMsg (Err err)

                        Ok (( key_, decoder ) :: []) ->
                            case Decode.decodeValue decoder value of
                                Ok msg ->
                                    msg

                                Err err ->
                                    toBatchedMsg (Err (toError key_ err))

                        Ok decoderList ->
                            decoderList
                                |> List.foldl (toMsgResult value) (Ok [])
                                |> toBatchedMsg
                )


toMsgResult : Encode.Value -> ( String, Decode.Decoder msg ) -> Result Decode.Error (List msg) -> Result Decode.Error (List msg)
toMsgResult value ( key_, decoder ) acc =
    case ( acc, Decode.decodeValue decoder value ) of
        ( Ok msgs, Ok msg ) ->
            Ok (msg :: msgs)

        ( Ok _, Err err ) ->
            Err (toError key_ err)

        _ ->
            acc


toError : String -> Decode.Error -> Decode.Error
toError key_ error =
    Decode.errorToString error
        |> (++) (key_ ++ ": ")
        |> (\s -> Decode.Failure s Encode.null)


decoderMsgsByKey : List (ExternalMsg msg) -> Decode.Decoder (List ( String, Decode.Decoder msg ))
decoderMsgsByKey listExt =
    let
        decodersByKey decodedKey (ExternalMsg (Key key_) decoder) =
            if decodedKey == key_ then
                Just decoder

            else
                Nothing
    in
    Decode.succeed
        (\key_ ->
            case List.filterMap (decodersByKey key_) listExt of
                [] ->
                    Decode.fail ("ExternalMsg.Key for doesn't match: " ++ key_)

                decoders ->
                    Decode.succeed (List.map (Tuple.pair key_ << Decode.field "payload") decoders)
        )
        |> Decode.required "key" Decode.string
        |> Decode.resolve
