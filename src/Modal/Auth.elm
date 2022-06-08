module Modal.Auth exposing (AuthType(..), Model, Msg, decoderAuthType, encodeAuthType, init, update, view)

import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode



-- STATE


type Model
    = Model Internal


type alias Internal =
    { username : String
    , password : String
    , authType : AuthType
    }


type AuthType
    = SignUp
    | SignIn


init : AuthType -> ( Model, Cmd Msg )
init authType =
    ( Model
        { username = ""
        , password = ""
        , authType = authType
        }
    , Cmd.none
    )



-- INPUT


type Msg
    = NoOp



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            NoOp ->
                ( model, Cmd.none )



-- OUTPUT


view : Model -> Html Msg
view model =
    Html.text "Auth Modal"



-- ADAPTERS


encodeAuthType : AuthType -> Encode.Value
encodeAuthType authType =
    case authType of
        SignIn ->
            Encode.object [ ( "constructor", Encode.string "SignIn" ) ]

        SignUp ->
            Encode.object [ ( "constructor", Encode.string "SignUp" ) ]


decoderAuthType : Decode.Decoder AuthType
decoderAuthType =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "SignIn" ->
                        Decode.succeed SignIn

                    "SignUp" ->
                        Decode.succeed SignUp

                    _ ->
                        Decode.fail "Not a type constructor for Modal.Auth.AuthType"
            )
