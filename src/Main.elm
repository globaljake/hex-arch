module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import ExternalMsg
import Flags exposing (Flags)
import Html
import Json.Decode as Decode
import Json.Encode as Encode
import Modal exposing (Modal)
import Page exposing (Page)
import Session exposing (Session)
import Url exposing (Url)



-- STATE


type Model
    = Model Session Page Modal



-- INITIAL STATE


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    initChangedUrl (Session.make navKey flags.viewer) url


initChangedUrl : Session -> Url -> ( Model, Cmd Msg )
initChangedUrl session url =
    let
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
    | GotBatchedMsgs (Result Decode.Error (List Msg))



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
            initChangedUrl session url

        SessionMsg subMsg ->
            Session.update subMsg session
                |> Tuple.mapBoth (\s -> Model s page modal) (Cmd.map SessionMsg)

        PageMsg subMsg ->
            Page.update session subMsg page
                |> Tuple.mapBoth (\p -> Model session p modal) (Cmd.map PageMsg)

        ModalMsg subMsg ->
            Modal.update session subMsg modal
                |> Tuple.mapBoth (\m -> Model session page m) (Cmd.map ModalMsg)

        GotBatchedMsgs (Ok msgs) ->
            updateBatchedMsgs msgs (Model session page modal)

        GotBatchedMsgs (Err _) ->
            ( Model session page modal, Cmd.none )


updateBatchedMsgs : List Msg -> Model -> ( Model, Cmd Msg )
updateBatchedMsgs msgs model =
    List.foldl
        (\msg ( newModel, newCmd ) ->
            update msg newModel
                |> Tuple.mapSecond (\cmd -> Cmd.batch [ cmd, newCmd ])
        )
        ( model, Cmd.none )
        msgs



-- OUTPUT


view : Model -> Browser.Document Msg
view (Model session page modal) =
    -- TODO: rethink through layout / page / modal / notifications and how to view them
    -- create multiple layouts and display notifications and modals depending on the layout
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions (Model session page modal) =
    Sub.batch
        [ Session.subscriptions session
            |> Sub.map SessionMsg
        , Page.subscriptions page
            |> Sub.map PageMsg
        , Modal.subscriptions modal
            |> Sub.map ModalMsg
        , ExternalMsg.toSubscription GotBatchedMsgs <|
            List.concat
                [ Session.extMsgs
                    |> List.map (ExternalMsg.map SessionMsg)
                , Page.extMsgs
                    |> List.map (ExternalMsg.map PageMsg)
                , Modal.extMsgs
                    |> List.map (ExternalMsg.map ModalMsg)
                ]
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
