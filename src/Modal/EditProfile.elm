port module Modal.EditProfile exposing (Model, Msg, init, subscribe, update, view)

import Api.HexArch.Data.Thing as Thing exposing (Thing)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Port



-- STATE


type Model
    = Model Internal


type alias Internal =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model {}, Cmd.none )



-- INPUT


type Msg
    = ClickedButtonToGrabThing



-- TRANSITION


update : Cmd Msg -> Msg -> Model -> ( Model, Cmd Msg )
update close msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            ClickedButtonToGrabThing ->
                ( model
                , Cmd.batch
                    [ publish (Port.Added Thing.mock)
                    , close
                    ]
                )



-- OUTPUT


view : Model -> Html Msg
view model =
    Html.div [ Attributes.class "flex justify-center mt-20" ]
        [ Html.div [ Attributes.class "flex-col border rounded bg-white p-5" ]
            [ Html.span [ Attributes.class "flex mb-5 justify-center w-96" ]
                [ Html.text "this is a modal"
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



-- EVENTS


port editProfileEventPublish : Encode.Value -> Cmd msg


publish : Port.Event Thing -> Cmd Msg
publish event =
    editProfileEventPublish (Port.encodeEvent Thing.encode event)


port editProfileEventSubscribe : (Encode.Value -> msg) -> Sub msg


subscribe : (Result Decode.Error (Port.Event Thing) -> msg) -> Sub msg
subscribe tagger =
    editProfileEventSubscribe
        (tagger << Decode.decodeValue (Port.decoderEvent Thing.decoder))



-- SUBSCRIPTIONS


subscription : model -> Sub Msg
subscription model =
    Sub.none
