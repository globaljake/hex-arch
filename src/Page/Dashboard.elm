module Page.Dashboard exposing (Model, Msg, extMsgs, init, subscriptions, update, view)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import ExternalMsg exposing (ExternalMsg)
import ExternalMsg.ModalAsk as ModalAsk
import ExternalMsg.ThingFormNotify as ThingFormNotify
import Html exposing (Html)
import Html.Attributes as Attributes
import ModalRoute as ModalRoute
import Process
import Session exposing (Session)
import Task
import Ui.Template as Template



-- STATE


type Model
    = Model Internal


type alias Internal =
    { feed : List ()
    , thing : Maybe Thing
    }



-- INITIAL STATE


init : Session -> ( Model, Cmd Msg )
init session =
    ( Model { feed = [], thing = Nothing }
    , Cmd.batch
        [ Process.sleep 1000
            |> Task.attempt GotStuff
        , Process.sleep 2000
            |> Task.attempt GotOtherStuff
        ]
    )



-- INPUT


type Msg
    = GotStuff (Result () ())
    | GotOtherStuff (Result () ())
    | GotThingFormNotifyExtMsg ThingFormNotify.ExtMsg


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.none


extMsgs : Model -> List (ExternalMsg Msg)
extMsgs (Model model) =
    [ ThingFormNotify.extMsg GotThingFormNotifyExtMsg
    ]



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            GotStuff _ ->
                ( model
                , ModalAsk.open (ModalRoute.EditProfileModal ())
                )

            GotOtherStuff _ ->
                ( model
                , Cmd.batch
                    []
                )

            GotThingFormNotifyExtMsg (ThingFormNotify.GotThing thing) ->
                ( { model | thing = Just thing }
                , Cmd.none
                )



-- OUTPUT


view : Session -> Model -> Template.Content Msg
view session (Model model) =
    Template.content ( "Dashboard", viewContent model )


viewContent : Internal -> Html Msg
viewContent model =
    Html.div []
        [ Html.text "Im the Dashboard!"
        , case model.thing of
            Nothing ->
                Html.text ""

            Just thing ->
                Html.div [ Attributes.class "flex flex-col" ]
                    [ Html.span [] [ Html.text (Thing.firstName thing) ]
                    , Html.span [] [ Html.text (Thing.lastName thing) ]
                    ]
        ]
