module Page.Dashboard exposing (Model, Msg, extMsgs, init, subscriptions, update, view)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import ExternalMsg exposing (ExternalMsg)
import ExternalMsg.ModalAsk as ModalAsk
import ExternalMsg.ThingFormNotify as ThingFormNotify
import Html exposing (Html)
import Html.Attributes as Attributes
import Modal.Variant as ModalVariant
import Process
import Session exposing (Session)
import Task
import Ui.PageView as PageView exposing (PageView)



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



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            GotStuff _ ->
                ( model
                , ModalAsk.open (ModalVariant.EditProfileModal ())
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


view : Session -> Model -> PageView Msg
view session (Model model) =
    PageView.make (viewContent model)


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



-- PORTS


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.none


extMsgs : List (ExternalMsg Msg)
extMsgs =
    [ ThingFormNotify.extMsg GotThingFormNotifyExtMsg
    ]
