module Page.Login exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation as Navigation
import Flags exposing (Flags)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (RemoteData)
import Route
import Session exposing (Session)
import Task
import Ui.LayoutPage as LayoutPage exposing (LayoutPage)
import Viewer exposing (Viewer)



-- STATE


type Model
    = Model Internal


type alias Internal =
    { form : Form
    , response : RemoteData Http.Error Viewer
    }



-- TYPES


type alias Form =
    { username : String
    , password : String
    }



-- INITIAL STATE


init : Session -> ( Model, Cmd Msg )
init session =
    ( Model
        { form = { username = "", password = "" }
        , response = RemoteData.NotAsked
        }
    , Cmd.none
    )



-- INPUT


type Msg
    = ChangedUsername String
    | ChangedPassword String
    | SubmitedForm
    | GotViewer (Result Http.Error Viewer)
    | GotSessionEvent (Result Decode.Error Session.Event)
    | NoOp



-- TRANSITION


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            ChangedUsername val ->
                updateForm (\form -> { form | username = val }) model

            ChangedPassword val ->
                updateForm (\form -> { form | password = val }) model

            SubmitedForm ->
                ( model
                , Viewer.authenticate { username = model.form.username, password = model.form.password }
                    |> Task.attempt GotViewer
                )

            GotViewer (Ok viewer) ->
                ( model, Session.request (Session.StoreViewer viewer) )

            GotViewer (Err _) ->
                ( model, Cmd.none )

            GotSessionEvent (Ok event) ->
                ( model, Route.replaceUrl (Session.navKey session) Route.Dashboard )

            GotSessionEvent (Err _) ->
                ( model, Cmd.none )

            NoOp ->
                ( model, Cmd.none )


updateForm : (Form -> Form) -> Internal -> ( Internal, Cmd Msg )
updateForm f model =
    ( { model | form = f model.form }, Cmd.none )



-- OUTPUT


view : Session -> Model -> LayoutPage Msg
view session (Model model) =
    LayoutPage.constructor (viewContent model)


viewContent : Internal -> Html Msg
viewContent model =
    Html.div [ Attributes.class "flex justify-center items-center w-full -mt-32" ]
        [ Html.div [ Attributes.class "flex flex-col bg-white max-w-lg w-full p-4 shadow rounded" ]
            [ Html.div [ Attributes.class "text-center mb-2" ]
                [ Html.div [ Attributes.class "flex justify-center items-center py-4 pointer-events-none" ]
                    [ Html.img [ Attributes.class "w-40", Attributes.src "hex-arch-logo.svg" ] []
                    ]
                , Html.span [ Attributes.class "font-bold text-xl mb-4 text-gray-800" ] [ Html.text "Log In" ]
                ]
            , Html.form [ Events.onSubmit SubmitedForm ]
                [ Html.div [ Attributes.class "space-y-3 py-3 text-gray-800" ]
                    [ Html.input
                        [ Attributes.class "bg-gray-50 w-full p-3 rounded border border-gray-300"
                        , Attributes.value model.form.username
                        , Attributes.placeholder "Username"
                        , Events.onInput ChangedUsername
                        ]
                        []
                    , Html.input
                        [ Attributes.class "bg-gray-50 w-full p-3 rounded border border-gray-300"
                        , Attributes.type_ "password"
                        , Attributes.value model.form.password
                        , Attributes.placeholder "Password"
                        , Events.onInput ChangedPassword
                        ]
                        []
                    ]
                , Html.div [ Attributes.class "flex justify-end" ]
                    [ Html.button
                        [ Attributes.class "submit"
                        , Attributes.class "p-2 bg-blue-400 px-6 rounded font-bold text-white"
                        ]
                        [ Html.text "Log In" ]
                    ]
                ]
            ]
        ]



-- PORTS


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.batch
        [ Session.subscribe GotSessionEvent ]
