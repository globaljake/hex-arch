module Page exposing (Msg, Page, extMsgs, init, subscriptions, title, update, view)

import ExternalMsg exposing (ExternalMsg)
import ExternalMsg.SessionAsk as SessionAsk
import Html exposing (Html)
import Page.Dashboard as Dashboard
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Profile as Profile
import Route as Route exposing (Route)
import Session as Session exposing (Session)
import Ui.Header as Header
import Ui.Nav as Nav
import Ui.Template as Template exposing (Template)
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
                    , SessionAsk.clear
                    )

                Just Route.Dashboard ->
                    Dashboard.init session
                        |> Tuple.mapBoth Dashboard (Cmd.map DashboardMsg)

                Just Route.Profile ->
                    Profile.init viewer session
                        |> Tuple.mapBoth Profile (Cmd.map ProfileMsg)

        Nothing ->
            Login.init session
                |> Tuple.mapBoth Login (Cmd.map LoginMsg)



-- INPUT


type Msg
    = ClickedBack
    | LoginMsg Login.Msg
    | DashboardMsg Dashboard.Msg
    | ProfileMsg Profile.Msg



-- TRANSITION


update : Session -> Msg -> Page -> ( Page, Cmd Msg )
update session msg page =
    case ( msg, page ) of
        ( ClickedBack, _ ) ->
            ( page, Route.back (Session.navKey session) )

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


template : Session -> Page -> Template Msg
template session page =
    case page of
        NotFound ->
            Template.blank NotFound.view

        Login subModel ->
            Login.view session subModel
                |> Template.mapContent LoginMsg
                |> Template.blank

        Dashboard subModel ->
            Dashboard.view session subModel
                |> Template.mapContent DashboardMsg
                |> Template.standard
                    (Nav.make (Just Route.Dashboard))
                    (Header.make "Dashboard" (Just ClickedBack))

        Profile subModel ->
            Profile.view session subModel
                |> Template.mapContent ProfileMsg
                |> Template.standard
                    (Nav.make (Just Route.Profile))
                    (Header.make "Profile" (Just ClickedBack))


title : Session -> Page -> String
title session page =
    Template.toTitle (template session page)


view : Session -> Page -> Html Msg
view session page =
    Template.toHtml (template session page)


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


extMsgs : Page -> List (ExternalMsg Msg)
extMsgs page =
    case page of
        NotFound ->
            []

        Login subModel ->
            []

        Dashboard subModel ->
            Dashboard.extMsgs subModel
                |> List.map (ExternalMsg.map DashboardMsg)

        Profile subModel ->
            []
