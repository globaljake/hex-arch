port module Session exposing
    ( Event(..)
    , ModuleRequest(..)
    , Msg
    , Session
    , make
    , navKey
    , request
    , subscribe
    , subscriptions
    , update
    , viewer
    )

import Browser.Navigation as Navigation
import Json.Decode as Decode
import Json.Encode as Encode
import ModuleRequest
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
    = GotModuleRequest (Result Decode.Error ModuleRequest)



-- TRANSITION


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        GotModuleRequest (Ok (StoreViewer v)) ->
            ( LoggedIn (navKey session) v
            , publish (UpdatedViewer v)
            )

        GotModuleRequest (Ok ClearSession) ->
            ( Guest (navKey session)
            , publish ClearedSession
            )

        GotModuleRequest (Err _) ->
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



-- MODULE REQUEST


type ModuleRequest
    = StoreViewer Viewer
    | ClearSession


port sessionSendRequest : Encode.Value -> Cmd msg


request : ModuleRequest -> Cmd msg
request moduleRequest =
    sessionSendRequest <|
        case moduleRequest of
            StoreViewer viewer_ ->
                ModuleRequest.encode "StoreViewer" (Viewer.encode viewer_)

            ClearSession ->
                ModuleRequest.encode "ClearSession" Encode.null


port sessionReceiveRequest : (Encode.Value -> msg) -> Sub msg


moduleRequests : (Result Decode.Error ModuleRequest -> Msg) -> Sub Msg
moduleRequests tagger =
    let
        decoder_ =
            ModuleRequest.decoder
                (\( constructor, payloadField ) ->
                    case constructor of
                        "StoreViewer" ->
                            Decode.map StoreViewer (Decode.field payloadField Viewer.decoder)

                        "ClearSession" ->
                            Decode.succeed ClearSession

                        _ ->
                            Decode.fail (ModuleRequest.failMessage constructor)
                )
    in
    sessionReceiveRequest (tagger << Decode.decodeValue decoder_)



-- PUB / SUB


type Event
    = UpdatedViewer Viewer
    | ClearedSession


port sessionPublish : Encode.Value -> Cmd msg


publish : Event -> Cmd Msg
publish event =
    sessionPublish <|
        case event of
            UpdatedViewer viewer_ ->
                ModuleRequest.encode "UpdatedViewer" (Viewer.encode viewer_)

            ClearedSession ->
                ModuleRequest.encode "ClearedSession" Encode.null


port sessionSubscribe : (Encode.Value -> msg) -> Sub msg


subscribe : (Result Decode.Error Event -> msg) -> Sub msg
subscribe tagger =
    let
        decoder_ =
            ModuleRequest.decoder
                (\( constructor, payloadField ) ->
                    case constructor of
                        "UpdatedViewer" ->
                            Decode.map UpdatedViewer (Decode.field payloadField Viewer.decoder)

                        "ClearedSession" ->
                            Decode.succeed ClearedSession

                        _ ->
                            Decode.fail (ModuleRequest.failMessage constructor)
                )
    in
    sessionSubscribe (tagger << Decode.decodeValue decoder_)



-- SUBSCRIPTIONS


subscriptions : Session -> Sub Msg
subscriptions session =
    moduleRequests GotModuleRequest
