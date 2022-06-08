module Page.Dashboard.Main exposing (Model, Msg, init, subscriptions, update, view)

import Flags exposing (Flags)
import Html exposing (Html)
import Modal
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
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( Model { feed = [] }
    , Cmd.batch
        [ Process.sleep 1000
            |> Task.attempt GotStuff
        , Process.sleep 4000
            |> Task.attempt GotOtherStuff
        ]
    )



-- INPUT


type Msg
    = GotStuff (Result () ())
    | GotOtherStuff (Result () ())
    | NoOp



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            GotStuff _ ->
                ( model
                , Cmd.batch
                    [ Toast.add Toast.Hey
                    , Toast.add Toast.ImAToast
                    , Toast.add Toast.Hey
                    , Toast.add Toast.LookAtMe
                    , Modal.open (Modal.BuyCoinsConfig ())
                    ]
                )

            GotOtherStuff _ ->
                ( model
                , Cmd.batch
                    [ Toast.remove Toast.Hey
                    , Toast.remove Toast.ImAToast
                    , Modal.close
                    ]
                )

            NoOp ->
                ( model, Cmd.none )



-- OUTPUT


view : Session -> Model -> LayoutPage Msg
view session (Model model) =
    LayoutPage.constructor viewContent


viewContent : Html Msg
viewContent =
    Html.div []
        []



-- PORTS


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.none
