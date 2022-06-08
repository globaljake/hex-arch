module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Flags exposing (Flags)
import Html
import Json.Encode as Encode
import Modal exposing (Modal)
import Page exposing (Page)
import Services
import Session exposing (Session)
import Url exposing (Url)



-- STATE


type Model
    = Model Session Page Modal



-- INITIAL STATE


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        session =
            Session.make navKey flags.viewer

        ( page, pageCmd ) =
            Page.init url session

        ( modal, modalCmd ) =
            Modal.init Nothing
    in
    ( Model session page modal
    , Cmd.batch
        [ Cmd.map PageMsg pageCmd
        , Cmd.map ModalMsg modalCmd
        ]
    )



-- INPUT


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | SessionMsg Session.Msg
    | PageMsg Page.Msg
    | ModalMsg Modal.Msg



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model session page modal) =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( Model session page modal
                    , Navigation.pushUrl (Session.navKey session) (Url.toString url)
                    )

                Browser.External href ->
                    ( Model session page modal
                    , Navigation.load href
                    )

        ChangedUrl url ->
            Page.init url session
                |> Tuple.mapBoth (\p -> Model session p modal) (Cmd.map PageMsg)

        SessionMsg subMsg ->
            Session.update subMsg session
                |> Tuple.mapBoth (\s -> Model s page modal) (Cmd.map SessionMsg)

        PageMsg subMsg ->
            Page.update session subMsg page
                |> Tuple.mapBoth (\p -> Model session p modal) (Cmd.map PageMsg)

        ModalMsg subMsg ->
            Modal.update session subMsg modal
                |> Tuple.mapBoth (\m -> Model session page m) (Cmd.map ModalMsg)



-- OUTPUT


view : Model -> Browser.Document Msg
view (Model session page modal) =
    let
        ( title, content ) =
            Page.layout PageMsg
                { session = session
                , page = page
                , viewServices =
                    Modal.view modal
                        |> Html.map ModalMsg
                }
    in
    { title = title, body = [ content ] }



-- PORTS


subscriptions : Model -> Sub Msg
subscriptions (Model session page modal) =
    Sub.batch
        [ Session.subscriptions session
            |> Sub.map SessionMsg
        , Page.subscriptions page
            |> Sub.map PageMsg
        , Modal.subscriptions
            |> Sub.map ModalMsg
        ]



-- MAIN


main : Program Encode.Value Model Msg
main =
    Browser.application
        { init = init << Flags.fromValue
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
