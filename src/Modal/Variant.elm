module Modal.Variant exposing (Variant(..), decoder, encode)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode


type Variant
    = SignInModal ()
    | EditProfileModal ()


encode : Variant -> Encode.Value
encode variant =
    case variant of
        SignInModal _ ->
            Encode.object
                [ ( "constructor", Encode.string "SignInModal" )
                , ( "payload", Encode.null )
                ]

        EditProfileModal _ ->
            Encode.object [ ( "constructor", Encode.string "EditProfileModal" ) ]


decoder : Decode.Decoder Variant
decoder =
    Decode.field "constructor" Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "SignInModal" ->
                        Decode.succeed (SignInModal ())

                    "EditProfileModal" ->
                        Decode.succeed (EditProfileModal ())

                    _ ->
                        Decode.fail "Not a type constructor for Modal.Variant"
            )
