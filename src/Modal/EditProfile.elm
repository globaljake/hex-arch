module Modal.EditProfile exposing (Model, Msg, init, update, view)

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
