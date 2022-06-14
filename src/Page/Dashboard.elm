module Page.Dashboard exposing (Model, Msg, init, receivers, subscriptions, update, view)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode
import Modal
import Process
import Relay
import Session exposing (Session)
import Task
import Toast
import Ui.PageView as PageView exposing (PageView)
import Ui.ThingForm as ThingForm



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
    | GotThingFromThingForm (Result Decode.Error Thing)
    | GotRelayThingForm Thing



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            GotStuff _ ->
                ( model
                , Modal.open Modal.EditProfileModal
                )

            GotOtherStuff _ ->
                ( model
                , Cmd.batch
                    []
                )

            GotThingFromThingForm (Ok thing) ->
                ( { model | thing = Just thing }
                , Modal.close
                )

            GotThingFromThingForm (Err _) ->
                ( model, Cmd.none )

            GotRelayThingForm thing ->
                ( { model | thing = Just thing }
                , Modal.close
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
    Sub.batch
        []


receivers : List (Relay.Receiver Msg)
receivers =
    [ ThingForm.receiver GotRelayThingForm
    ]
