module Modal.SignIn exposing (Model, Msg, init, update, view)

import ExternalMsg.Modal as ExtMsgModal
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events



-- STATE


type Model
    = Model Internal


type alias Internal =
    { username : String
    , password : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        { username = ""
        , password = ""
        }
    , Cmd.none
    )



-- INPUT


type Msg
    = ClickedCloseButton



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            ClickedCloseButton ->
                ( model, ExtMsgModal.close )



-- OUTPUT


view : Model -> Html Msg
view model =
    Html.div [ Attributes.class "flex justify-center mt-20" ]
        [ Html.div [ Attributes.class "flex-col border rounded bg-white p-5" ]
            [ Html.span [ Attributes.class "flex mb-5 justify-center w-96" ]
                [ Html.text "this is the sign in modal"
                ]
            , Html.button [ Events.onClick ClickedCloseButton ] [ Html.text "Internal Close" ]
            ]
        ]
