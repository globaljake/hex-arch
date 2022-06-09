module Page.Dashboard.Main exposing (Model, Msg, init, subscriptions, update, view)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import Flags exposing (Flags)
import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode
import Modal
import Modal.EditProfile as EditProfile
import Port
import Process
import Session exposing (Session)
import Task
import Toast
import Ui.LayoutPage as LayoutPage exposing (LayoutPage)
import Viewer exposing (Viewer)



-- STATE


type Model
    = Model Internal


type alias Internal =
    { feed : List ()
    , thing : Maybe Thing
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( Model { feed = [], thing = Nothing }
    , Cmd.batch
        [ Process.sleep 3000
            |> Task.attempt GotStuff
        , Process.sleep 4000
            |> Task.attempt GotOtherStuff
        ]
    )



-- INPUT


type Msg
    = GotStuff (Result () ())
    | GotOtherStuff (Result () ())
    | GotEditProfileEvent (Result Decode.Error (Port.Event Thing))



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            GotStuff _ ->
                ( model
                , Cmd.batch
                    [ Modal.open Modal.EditProfileModal
                    ]
                )

            GotOtherStuff _ ->
                ( model
                , Cmd.batch
                    [ Toast.add Toast.Hey
                    , Toast.add Toast.ImAToast
                    , Toast.add Toast.Hey
                    , Toast.add Toast.LookAtMe
                    , Toast.remove Toast.Hey
                    , Toast.remove Toast.ImAToast
                    ]
                )

            GotEditProfileEvent (Ok event) ->
                updateEditProfieEvent event model

            GotEditProfileEvent _ ->
                ( model, Cmd.none )


updateEditProfieEvent : Port.Event Thing -> Internal -> ( Internal, Cmd msg )
updateEditProfieEvent event model =
    case event of
        Port.Added thing ->
            ( { model | thing = Just thing }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- OUTPUT


view : Session -> Model -> LayoutPage Msg
view session (Model model) =
    LayoutPage.constructor viewContent


viewContent : Html Msg
viewContent =
    Html.div [ Attributes.class "bg-black" ] [ Html.text "Im the Dashboard!" ]



-- PORTS


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.batch [ EditProfile.subscribe GotEditProfileEvent ]
