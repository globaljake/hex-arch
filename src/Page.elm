module Page exposing (Msg, Page, init, layout, receivers, subscriptions, update)

import ExternalMsg
import ExternalMsg.Session as ExtMsgSession
import Html exposing (Html)
import Page.Dashboard as Dashboard
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Profile as Profile
import Route as Route exposing (Route)
import Session as Session exposing (Session)
import Ui.PageView as PageView exposing (PageView)
import Url exposing (Url)



-- STATE


type Page
    = NotFound
    | Login Login.Model
    | Dashboard Dashboard.Model
    | Profile Profile.Model


init : Url -> Session -> ( Page, Cmd Msg )
init url session =
    case Session.viewer session of
        Just viewer ->
            case Route.fromUrl url of
                Nothing ->
                    ( NotFound, Cmd.none )

                Just Route.Login ->
                    Dashboard.init session
                        |> Tuple.mapBoth Dashboard (Cmd.map DashboardMsg)

                Just Route.Logout ->
                    ( NotFound
                    , ExtMsgSession.clear
                    )

                Just Route.Dashboard ->
                    Dashboard.init session
                        |> Tuple.mapBoth Dashboard (Cmd.map DashboardMsg)

                Just Route.Profile ->
                    Profile.init viewer session
                        |> Tuple.mapBoth Profile (Cmd.map ProfileMsg)

        Nothing ->
            -- Dashboard.init session
            --     |> Tuple.mapBoth Dashboard (Cmd.map DashboardMsg)
            Login.init session
                |> Tuple.mapBoth Login (Cmd.map LoginMsg)



-- INPUT


type Msg
    = LoginMsg Login.Msg
    | DashboardMsg Dashboard.Msg
    | ProfileMsg Profile.Msg



-- TRANSITION


update : Session -> Msg -> Page -> ( Page, Cmd Msg )
update session msg page =
    case ( msg, page ) of
        ( LoginMsg subMsg, Login subModel ) ->
            Login.update session subMsg subModel
                |> Tuple.mapBoth Login (Cmd.map LoginMsg)

        ( DashboardMsg subMsg, Dashboard subModel ) ->
            Dashboard.update subMsg subModel
                |> Tuple.mapBoth Dashboard (Cmd.map DashboardMsg)

        ( ProfileMsg subMsg, Profile subModel ) ->
            Profile.update session subMsg subModel
                |> Tuple.mapBoth Profile (Cmd.map ProfileMsg)

        _ ->
            ( page, Cmd.none )



-- OUTPUT


layout : (Msg -> msg) -> { session : Session, page : Page, viewServices : Html msg } -> ( String, Html msg )
layout tagger { session, page, viewServices } =
    case page of
        NotFound ->
            ( "Not Found"
            , NotFound.view
                |> PageView.view PageView.Blank
            )

        Login subModel ->
            ( "Login"
            , Login.view session subModel
                |> PageView.map (tagger << LoginMsg)
                |> PageView.view PageView.Blank
            )

        Dashboard subModel ->
            ( "Dashboard"
            , Dashboard.view session subModel
                |> PageView.map (tagger << DashboardMsg)
                |> PageView.view
                    (PageView.StandardWithSidebarNav
                        { header = "Dashboard"
                        , activeRoute = Just Route.Dashboard
                        , viewServices = viewServices
                        }
                    )
            )

        Profile subModel ->
            ( "Profile"
            , Profile.view session subModel
                |> PageView.map (tagger << ProfileMsg)
                |> PageView.view
                    (PageView.StandardWithSidebarNav
                        { header = "Profile"
                        , activeRoute = Just Route.Profile
                        , viewServices = viewServices
                        }
                    )
            )



-- SUBSCRIPTIONS


subscriptions : Page -> Sub Msg
subscriptions page =
    case page of
        NotFound ->
            Sub.none

        Login subModel ->
            Login.subscriptions subModel
                |> Sub.map LoginMsg

        Dashboard subModel ->
            Dashboard.subscriptions subModel
                |> Sub.map DashboardMsg

        Profile subModel ->
            Profile.subscriptions subModel
                |> Sub.map ProfileMsg



-- RELAY


receivers : List (ExternalMsg.Receiver Msg)
receivers =
    List.concat
        [ Login.receivers
            |> List.map (ExternalMsg.map LoginMsg)
        , Dashboard.receivers
            |> List.map (ExternalMsg.map DashboardMsg)
        ]
