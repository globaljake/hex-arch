module Modal.EditProfile exposing (Model, Msg, extMsgs, init, update, view)

import ExternalMsg exposing (ExternalMsg)
import ExternalMsg.ModalAsk as ModalAsk
import ExternalMsg.ThingFormNotify as ThingFormNotify
import Html exposing (Html)
import Html.Attributes as Attributes
import Ui.ThingForm as ThingForm



-- STATE


type Model
    = Model Internal


type alias Internal =
    { thingForm : ThingForm.Model }


init : ( Model, Cmd Msg )
init =
    let
        ( thingForm, thingFormCmd ) =
            ThingForm.init
    in
    ( Model { thingForm = thingForm }
    , Cmd.map ThingFormMsg thingFormCmd
    )



-- INPUT


type Msg
    = ThingFormMsg ThingForm.Msg
    | GotThingFormNotifyExtMsg ThingFormNotify.ExtMsg



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            ThingFormMsg subMsg ->
                ThingForm.update subMsg model.thingForm
                    |> (\( subModel, subCmd ) ->
                            ( { model | thingForm = subModel }
                            , Cmd.map ThingFormMsg subCmd
                            )
                       )

            GotThingFormNotifyExtMsg extMsg ->
                ( model
                , ModalAsk.close
                )



-- OUTPUT


view : Model -> Html Msg
view (Model model) =
    Html.div [ Attributes.class "flex justify-center mt-20" ]
        [ Html.div [ Attributes.class "flex-col border rounded bg-white p-5" ]
            [ Html.span [ Attributes.class "flex mb-5 justify-center w-96" ]
                [ Html.text "this is a modal"
                ]
            , ThingForm.view model.thingForm
                |> Html.map ThingFormMsg
            ]
        ]



-- SUBSCRIPTIONS


subscription : model -> Sub Msg
subscription model =
    Sub.none


extMsgs : List (ExternalMsg Msg)
extMsgs =
    [ ThingFormNotify.extMsg GotThingFormNotifyExtMsg
    ]
