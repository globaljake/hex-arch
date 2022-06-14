module Session exposing
    ( Msg
    , RelayExternalMsg(..)
    , Session
    , clear
    , externalReceiver
    , make
    , navKey
    , subscriptions
    , update
    , updateViewer
    , viewer
    )

import Browser.Navigation as Navigation
import Json.Decode as Decode
import Json.Encode as Encode
import Relay
import Route
import Viewer exposing (Viewer)



-- STATE


type Session
    = Guest Navigation.Key
    | LoggedIn Navigation.Key Viewer



-- INITIAL STATE


make : Navigation.Key -> Maybe Viewer -> Session
make navKey_ maybeViewer =
    case maybeViewer of
        Just viewer_ ->
            LoggedIn navKey_ viewer_

        Nothing ->
            Guest navKey_



-- INPUT


type Msg
    = GotRelayInternalMsg RelayInternalMsg
    | GotRelayError Decode.Error



-- TRANSITION


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        GotRelayInternalMsg subMsg ->
            updateRelayInternalMsg subMsg session

        GotRelayError err ->
            ( session, Cmd.none )


updateRelayInternalMsg : RelayInternalMsg -> Session -> ( Session, Cmd Msg )
updateRelayInternalMsg msg session =
    case msg of
        UpdateViewer viewer_ ->
            ( LoggedIn (navKey session) viewer_
            , Cmd.batch
                [ Relay.publish (externalMessage Authenticated)
                , Viewer.store viewer_
                ]
            )

        Clear ->
            ( Guest (navKey session)
            , Cmd.batch
                [ Relay.publish (externalMessage SessionCleared)
                , Viewer.clear
                , Route.replaceUrl (navKey session) Route.Login
                ]
            )



-- OUTPUT


navKey : Session -> Navigation.Key
navKey session =
    case session of
        LoggedIn navKey_ _ ->
            navKey_

        Guest navKey_ ->
            navKey_


viewer : Session -> Maybe Viewer
viewer session =
    case session of
        LoggedIn _ viewer_ ->
            Just viewer_

        Guest _ ->
            Nothing



-- INTERNAL RELAY


type RelayInternalMsg
    = UpdateViewer Viewer
    | Clear


internalAdapter : Relay.Adapter
internalAdapter =
    Relay.internal "Session"


internalMessage : RelayInternalMsg -> Relay.Message
internalMessage msg =
    Relay.message internalAdapter encodeRelayInternalMsg msg


updateViewer : Viewer -> Cmd msg
updateViewer viewer_ =
    Relay.publish (internalMessage (UpdateViewer viewer_))


clear : Cmd msg
clear =
    Relay.publish (internalMessage Clear)


internalReceiver : (RelayInternalMsg -> msg) -> Relay.Receiver msg
internalReceiver tagger =
    Relay.receiver internalAdapter (Decode.map tagger decoderRelayInternalMsg)


encodeRelayInternalMsg : RelayInternalMsg -> Encode.Value
encodeRelayInternalMsg msg =
    case msg of
        UpdateViewer viewer_ ->
            Encode.object
                [ ( "constructor", Encode.string "UpdateViewer" )
                , ( "payload", Viewer.encode viewer_ )
                ]

        Clear ->
            Encode.object [ ( "constructor", Encode.string "Clear" ) ]


decoderRelayInternalMsg : Decode.Decoder RelayInternalMsg
decoderRelayInternalMsg =
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



--  EXTERNAL RELAY


type RelayExternalMsg
    = Authenticated
    | SessionCleared


externalAdapter : Relay.Adapter
externalAdapter =
    Relay.external "Session"


externalMessage : RelayExternalMsg -> Relay.Message
externalMessage msg =
    Relay.message externalAdapter encodeRelayExternalMsg msg


externalReceiver : (RelayExternalMsg -> msg) -> Relay.Receiver msg
externalReceiver tagger =
    Relay.receiver externalAdapter (Decode.map tagger decoderRelayExternalMsg)


encodeRelayExternalMsg : RelayExternalMsg -> Encode.Value
encodeRelayExternalMsg input =
    case input of
        Authenticated ->
            Encode.object [ ( "constructor", Encode.string "Authenticated" ) ]

        SessionCleared ->
            Encode.object [ ( "constructor", Encode.string "SessionCleared" ) ]


decoderRelayExternalMsg : Decode.Decoder RelayExternalMsg
decoderRelayExternalMsg =
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



-- SUBSCRIPTIONS


subscriptions : Session -> Sub Msg
subscriptions session =
    Sub.batch
        [ Relay.subscribe GotRelayError
            [ internalReceiver GotRelayInternalMsg
            ]
        , Viewer.onChangeFromOtherTab
            (\x ->
                case x of
                    Ok viewer_ ->
                        GotRelayInternalMsg (UpdateViewer viewer_)

                    Err err ->
                        GotRelayError err
            )
        ]
