module Session exposing
    ( Msg
    , Session
    , make
    , navKey
    , receivers
    , subscriptions
    , update
    , viewer
    )

import Browser.Navigation as Navigation
import ExternalMsg
import ExternalMsg.Session as ExtMsgSession
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
    = GotExternalMsg ExtMsgSession.AskMsg
    | GotRelayError Decode.Error



-- TRANSITION


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        GotExternalMsg subMsg ->
            updateExternalMsg subMsg session

        GotRelayError err ->
            ( session, Cmd.none )


updateExternalMsg : ExtMsgSession.AskMsg -> Session -> ( Session, Cmd Msg )
updateExternalMsg msg session =
    case msg of
        ExtMsgSession.UpdateViewer viewer_ ->
            ( LoggedIn (navKey session) viewer_
            , Cmd.batch
                [ ExtMsgSession.inform ExtMsgSession.Authenticated
                , Viewer.store viewer_
                ]
            )

        ExtMsgSession.Clear ->
            ( Guest (navKey session)
            , Cmd.batch
                [ ExtMsgSession.inform ExtMsgSession.SessionCleared
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
                        GotExternalMsg (ExtMsgSession.UpdateViewer viewer_)

                    Err err ->
                        GotRelayError err
            )
        ]


receivers : List (ExternalMsg.Receiver Msg)
receivers =
    [ ExtMsgSession.askReceiver GotExternalMsg
    ]
