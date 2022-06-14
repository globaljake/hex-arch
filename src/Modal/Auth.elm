module Modal.Auth exposing (Model, Msg, Variant(..), decoderVariant, encodeVariant, init, update, view)

import Html exposing (Html, var)
import Json.Decode as Decode
import Json.Encode as Encode



-- STATE


type Model
    = Model Internal


type alias Internal =
    { username : String
    , password : String
    , variant : Variant
    }


type Variant
    = SignUp
    | SignIn


init : Variant -> ( Model, Cmd Msg )
init variant =
    ( Model
        { username = ""
        , password = ""
        , variant = variant
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


encodeVariant : Variant -> Encode.Value
encodeVariant variant =
    case variant of
        SignIn ->
            Encode.object [ ( "constructor", Encode.string "SignIn" ) ]

        SignUp ->
            Encode.object [ ( "constructor", Encode.string "SignUp" ) ]


decoderVariant : Decode.Decoder Variant
decoderVariant =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "SignIn" ->
                        Decode.succeed SignIn

                    "SignUp" ->
                        Decode.succeed SignUp

                    _ ->
                        Decode.fail "Not a type constructor for Modal.Auth.Variant"
            )
