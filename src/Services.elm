module Services exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser
import Browser.Navigation as Navigation
import Flags as Flags exposing (Flags)
import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Route as Route exposing (Route)
import Toast as Toast exposing (Toast)



-- STATE


type Model
    = Model Internal


type alias Internal =
    { toast : Toast
    }


init : Flags -> Navigation.Key -> ( Model, Cmd Msg )
init flags navKey_ =
    ( Model { toast = Toast.empty }
    , Cmd.none
    )



-- INPUT


type Msg
    = ToastMsg Toast.Msg
    | NoOp



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            ToastMsg subMsg ->
                Toast.update subMsg model.toast
                    |> Tuple.mapBoth (\newToast -> { model | toast = newToast }) (Cmd.map ToastMsg)

            NoOp ->
                ( model, Cmd.none )



-- OUTPUT


view : Model -> Html Msg
view (Model model) =
    Html.div [ Attributes.class "absolute inset-0 bg-blue-100" ]
        [ Toast.view model.toast
            |> Html.map ToastMsg
        ]



-- PORTS


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.batch
        [ Toast.subscriptions model.toast
            |> Sub.map ToastMsg
        ]
