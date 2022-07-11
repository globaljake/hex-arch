module Ui.ThingForm exposing (Model, Msg, init, subscriptions, update, view)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import ExternalMsg.ThingFormNotify as ThingFormNotify
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events



-- STATE


type Model
    = Model Internal


type alias Internal =
    { thing : Maybe Thing }


init : ( Model, Cmd Msg )
init =
    ( Model { thing = Just Thing.mock }
    , Cmd.none
    )



-- INPUT


type Msg
    = ClickedButtonToGrabThing


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            ClickedButtonToGrabThing ->
                ( model
                , ThingFormNotify.send Thing.mock
                )



-- OUTPUT


view : Model -> Html Msg
view model =
    Html.div [ Attributes.class "flex justify-center" ]
        [ Html.div [ Attributes.class "flex-col border rounded bg-white p-5" ]
            [ Html.span [ Attributes.class "flex mb-5 justify-center w-96" ]
                [ Html.text "Im the Thing Form"
                ]
            , Html.div [ Attributes.class "flex justify-center" ]
                [ Html.button
                    [ Attributes.class "bg-blue-500 rounded-full px-4 py-2 text-white"
                    , Events.onClick ClickedButtonToGrabThing
                    ]
                    [ Html.text "Publish Thing"
                    ]
                ]
            ]
        ]
