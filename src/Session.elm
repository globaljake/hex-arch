module Session exposing
    ( Msg
    , Session
    , extMsgs
    , make
    , navKey
    , subscriptions
    , update
    , viewer
    )

import Browser.Navigation as Navigation
import ExternalMsg exposing (ExternalMsg)
import ExternalMsg.SessionAsk as SessionAsk
import ExternalMsg.SessionInform as SessionInform
import Json.Decode as Decode
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
    = GotSessionAskExtMsg SessionAsk.ExtMsg
    | GotRelayError Decode.Error



-- TRANSITION


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        GotSessionAskExtMsg subMsg ->
            updateSessionAskExtMsg subMsg session

        GotRelayError err ->
            ( session, Cmd.none )


updateSessionAskExtMsg : SessionAsk.ExtMsg -> Session -> ( Session, Cmd Msg )
updateSessionAskExtMsg msg session =
    case msg of
        SessionAsk.UpdateViewer viewer_ ->
            ( LoggedIn (navKey session) viewer_
            , Cmd.batch
                [ SessionInform.send SessionInform.Authenticated
                , Viewer.store viewer_
                ]
            )

        SessionAsk.Clear ->
            ( Guest (navKey session)
            , Cmd.batch
                [ SessionInform.send SessionInform.SessionCleared
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



-- SUBSCRIPTIONS


subscriptions : Session -> Sub Msg
subscriptions session =
    Sub.batch
        [ Viewer.onChangeFromOtherTab
            (\x ->
                case x of
                    Ok viewer_ ->
                        GotSessionAskExtMsg (SessionAsk.UpdateViewer viewer_)

                    Err err ->
                        GotRelayError err
            )
        ]


extMsgs : List (ExternalMsg Msg)
extMsgs =
    [ SessionAsk.extMsg GotSessionAskExtMsg
    ]
