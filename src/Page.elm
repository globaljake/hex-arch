module Page exposing (Msg, Page, init, layout, subscriptions, update)

import Html exposing (Html)
import Page.Dashboard as Dashboard
import Page.Forms as Forms
import Page.Login as Login
import Page.NotFound as NotFound
import Relay
import Route as Route exposing (Route)
import Session as Session exposing (Session)
import Ui.PageView as PageView exposing (PageView)
import Url exposing (Url)
import Viewer



-- STATE


type Page
    = NotFound
    | Login Login.Model
    | Dashboard Dashboard.Model
    | Forms Forms.Model


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
                    , Session.clear
                    )

                Just Route.Dashboard ->
                    Dashboard.init session
                        |> Tuple.mapBoth Dashboard (Cmd.map DashboardMsg)

                Just Route.Forms ->
                    Forms.init viewer session
                        |> Tuple.mapBoth Forms (Cmd.map FormsMsg)

        Nothing ->
            -- Dashboard.init session
            --     |> Tuple.mapBoth Dashboard (Cmd.map DashboardMsg)
            Login.init session
                |> Tuple.mapBoth Login (Cmd.map LoginMsg)



-- INPUT


type Msg
    = LoginMsg Login.Msg
    | DashboardMsg Dashboard.Msg
    | FormsMsg Forms.Msg



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

        ( FormsMsg subMsg, Forms subModel ) ->
            Forms.update session subMsg subModel
                |> Tuple.mapBoth Forms (Cmd.map FormsMsg)

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

        Forms subModel ->
            ( "Forms"
            , Forms.view session subModel
                |> PageView.map (tagger << FormsMsg)
                |> PageView.view
                    (PageView.StandardWithSidebarNav
                        { header = "Forms"
                        , activeRoute = Just Route.Forms
                        , viewServices = viewServices
                        }
                    )
            )



-- PORTS


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

        Forms subModel ->
            Forms.subscriptions subModel
                |> Sub.map FormsMsg
