module Viewer exposing (Viewer, authenticate, decoder, encode, hexArchAuthToken)

import Api.HexArch.Api as HexArchApi
import Http
import Http.Extra as Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Task exposing (Task)



-- TYPES


type Viewer
    = Viewer Internal


type alias Internal =
    { hexArchAuthToken : HexArchApi.AuthToken
    }



-- PROPERTIES


hexArchAuthToken : Viewer -> HexArchApi.AuthToken
hexArchAuthToken (Viewer viewer) =
    viewer.hexArchAuthToken



-- ADAPTERS


encode : Viewer -> Encode.Value
encode viewer =
    Encode.object
        [ ( "hexArchAuthToken", HexArchApi.encodeAuthToken (hexArchAuthToken viewer) )
        ]


decoder : Decode.Decoder Viewer
decoder =
    Decode.succeed Internal
        |> Decode.required "hexArchAuthToken" HexArchApi.decoderAuthToken
        |> Decode.map Viewer



-- HTTP


authenticate : { username : String, password : String } -> Task Http.Error Viewer
authenticate params =
    authenticateHexArch params


authenticateHexArch : { username : String, password : String } -> Task Http.Error Viewer
authenticateHexArch { username, password } =
    let
        decoder_ : Decode.Decoder (HexArchApi.AuthToken -> Viewer)
        decoder_ =
            Decode.succeed (\at -> Viewer { hexArchAuthToken = at })

        body =
            (Http.jsonBody << Encode.object)
                [ ( "password", Encode.string password )
                , ( "username", Encode.string username )
                ]
    in
    HexArchApi.authenticate body decoder_
