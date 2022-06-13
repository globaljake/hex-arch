module Session exposing
    ( Event(..)
    , Msg
    , Session
    , clear
    , make
    , navKey
    , subscribe
    , subscriptions
    , update
    , updateViewer
    , viewer
    )

import Adapter
import Browser.Navigation as Navigation
import Json.Decode as Decode
import Json.Encode as Encode
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
    = GotExternalInput (Result Decode.Error ExternalInput)



-- TRANSITION


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        GotExternalInput (Ok (UpdateViewer viewer_)) ->
            ( LoggedIn (navKey session) viewer_
            , Cmd.batch
                [ publish Authenticated
                , Viewer.store viewer_
                ]
            )

        GotExternalInput (Ok Clear) ->
            ( Guest (navKey session)
            , Cmd.batch
                [ publish SessionCleared
                , Viewer.clear
                , Route.replaceUrl (navKey session) Route.Login
                ]
            )

        GotExternalInput (Err err) ->
            ( session, Cmd.none )



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



-- External Input


type ExternalInput
    = UpdateViewer Viewer
    | Clear


updateViewer : Viewer -> Cmd msg
updateViewer viewer_ =
    Adapter.primarySessionAdapterSendMessage (encodeExternalInput (UpdateViewer viewer_))


clear : Cmd msg
clear =
    Adapter.primarySessionAdapterSendMessage (encodeExternalInput Clear)


externalInput : (Result Decode.Error ExternalInput -> Msg) -> Sub Msg
externalInput tagger =
    Adapter.primarySessionAdapterMessageReceiver
        (tagger << Decode.decodeValue decoderExternalInput)


encodeExternalInput : ExternalInput -> Encode.Value
encodeExternalInput input =
    case input of
        UpdateViewer viewer_ ->
            Encode.object
                [ ( "constructor", Encode.string "UpdateViewer" )
                , ( "payload", Viewer.encode viewer_ )
                ]

        Clear ->
            Encode.object [ ( "constructor", Encode.string "Clear" ) ]


decoderExternalInput : Decode.Decoder ExternalInput
decoderExternalInput =
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



--  EVENTS


type Event
    = Authenticated
    | SessionCleared


encodeEvent : Event -> Encode.Value
encodeEvent input =
    case input of
        Authenticated ->
            Encode.object [ ( "constructor", Encode.string "Authenticated" ) ]

        SessionCleared ->
            Encode.object [ ( "constructor", Encode.string "SessionCleared" ) ]


decoderEvent : Decode.Decoder Event
decoderEvent =
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


publish : Event -> Cmd Msg
publish event =
    Adapter.secondarySessionAdapterSendMessage (encodeEvent event)


subscribe : (Result Decode.Error Event -> msg) -> Sub msg
subscribe tagger =
    Adapter.secondarySessionAdapterMessageReceiver
        (tagger << Decode.decodeValue decoderEvent)



-- SUBSCRIPTIONS


subscriptions : Session -> Sub Msg
subscriptions session =
    Sub.batch
        [ externalInput GotExternalInput
        , Viewer.onChangeFromOtherTab (GotExternalInput << Result.map UpdateViewer)
        ]
