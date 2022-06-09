port module Session exposing
    ( Msg
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

import Browser.Navigation as Navigation
import Json.Decode as Decode
import Json.Encode as Encode
import Port
import String exposing (cons)
import Ui.LayoutPage exposing (constructor)
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
    = GotInstruction (Result Decode.Error (Port.Instruction Viewer))



-- TRANSITION


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        GotInstruction (Ok instruction) ->
            updateInstruction instruction session

        GotInstruction (Err err) ->
            ( session, Cmd.none )


updateInstruction : Port.Instruction Viewer -> Session -> ( Session, Cmd Msg )
updateInstruction instruction session =
    case instruction of
        Port.Add viewer_ ->
            ( LoggedIn (navKey session) viewer_
            , publish (Port.Added viewer_)
            )

        Port.Clear ->
            ( Guest (navKey session)
            , publish Port.Cleared
            )

        _ ->
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



-- INSTRUCTIONS


port sessionSendInstruction : Encode.Value -> Cmd msg


updateViewer : Viewer -> Cmd msg
updateViewer viewer_ =
    sessionSendInstruction (Port.encodeInstruction Viewer.encode (Port.Add viewer_))


clear : Cmd msg
clear =
    sessionSendInstruction (Port.encodeInstruction (\_ -> Encode.null) Port.Clear)


port sessionReceiveInstruction : (Encode.Value -> msg) -> Sub msg


instructions : (Result Decode.Error (Port.Instruction Viewer) -> Msg) -> Sub Msg
instructions tagger =
    sessionReceiveInstruction
        (tagger << Decode.decodeValue (Port.decoderInstruction Viewer.decoder))



-- EVENTS


port sessionEventPublish : Encode.Value -> Cmd msg


publish : Port.Event Viewer -> Cmd Msg
publish event =
    sessionEventPublish (Port.encodeEvent Viewer.encode event)


port sessionEventSubscribe : (Encode.Value -> msg) -> Sub msg


subscribe : (Result Decode.Error (Port.Event Viewer) -> msg) -> Sub msg
subscribe tagger =
    sessionEventSubscribe
        (tagger << Decode.decodeValue (Port.decoderEvent Viewer.decoder))



-- SUBSCRIPTIONS


subscriptions : Session -> Sub Msg
subscriptions session =
    instructions GotInstruction
