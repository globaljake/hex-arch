module Page.Profile exposing (Model, Msg, init, subscriptions, update, view)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import ExternalMsg.ModalAsk as ModalAsk
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import ModalRoute as ModalRoute
import Process
import Route
import Session exposing (Session)
import Task
import Toast
import Ui.Template as Template
import Viewer exposing (Viewer)



-- STATE


type Model
    = Model Internal


type alias Internal =
    { things : List Thing
    }



-- INITIAL STATE


init : Viewer -> Session -> ( Model, Cmd Msg )
init viewer session =
    ( Model { things = [] }
    , Cmd.batch
        [ Process.sleep 1000
            |> Task.attempt GotStuff
        , Process.sleep 5000
            |> Task.attempt GotOtherStuff
        , Thing.fetchAll (Viewer.hexArchAuthToken viewer)
            |> Task.attempt GotThings
        ]
    )



-- INPUT


type Msg
    = GotStuff (Result () ())
    | GotOtherStuff (Result () ())
    | GotThings (Result Http.Error (List Thing))
    | NoOp


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.none



-- TRANSITION


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            GotStuff _ ->
                ( model
                , ModalAsk.open (ModalRoute.SignInModal ())
                )

            GotOtherStuff _ ->
                ( model, Cmd.none )

            GotThings (Ok things) ->
                ( { model | things = things }, Cmd.none )

            GotThings (Err err) ->
                ( model, Cmd.none )

            NoOp ->
                ( model, Cmd.none )



-- OUTPUT


view : Session -> Model -> Template.Content Msg
view session (Model model) =
    Template.content ( "Profile", viewContent session model )


viewContent : Session -> Internal -> Html Msg
viewContent session model =
    Html.div [ Attributes.class "flex flex-col bg-white p-4 border rounded" ]
        [ viewTable model
        ]


viewTable : Internal -> Html Msg
viewTable model =
    Html.div [ Attributes.class "bg-gray-200 grid gap-px p-px rounded-t" ]
        [ Html.div [ Attributes.class "grid grid-cols-4 gap-px rounded-t overflow-hidden" ]
            [ viewTableHeaderCell "Id"
            , viewTableHeaderCell "First Name"
            , viewTableHeaderCell "Last Name"
            , viewTableHeaderCell "Is Inactive"
            ]
        , Html.div [ Attributes.class "bg-gray-200 grid gap-px" ] (List.map viewRow model.things)
        ]


viewRow : Thing -> Html Msg
viewRow thing =
    Html.div [ Attributes.class "grid grid-cols-4 gap-px" ]
        [ viewTableCell (Thing.id thing)
        , viewTableCell (Thing.firstName thing)
        , viewTableCell (Thing.lastName thing)
        , viewTableCell
            (if Thing.isActive thing then
                "True"

             else
                "False"
            )
        ]


viewTableHeaderCell : String -> Html Msg
viewTableHeaderCell name =
    Html.div [ Attributes.class "p-2 bg-gray-100" ] [ Html.text name ]


viewTableCell : String -> Html Msg
viewTableCell value =
    Html.div [ Attributes.class "p-2 bg-white" ] [ Html.text value ]
