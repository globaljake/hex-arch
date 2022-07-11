module ModalRoute exposing (ModalRoute(..), decoder, encode)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



-- TYPE


type ModalRoute
    = SignInModal ()
    | EditProfileModal ()



-- ENCODE / DECODE


encode : ModalRoute -> Encode.Value
encode route =
    case route of
        SignInModal _ ->
            Encode.object
                [ ( "constructor", Encode.string "SignInModal" )
                , ( "payload", Encode.null )
                ]

        EditProfileModal _ ->
            Encode.object [ ( "constructor", Encode.string "EditProfileModal" ) ]


decoder : Decode.Decoder ModalRoute
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
                        Decode.fail "Not a type constructor for ModalRoute"
            )
