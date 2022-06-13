port module Viewer exposing
    ( Viewer
    , authenticate
    , clear
    , decoder
    , encode
    , hexArchAuthToken
    , onChangeFromOtherTab
    , store
    )

import Api.HexArch.Api as HexArchApi
import Http
import Http.Extra as Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Task exposing (Task)



-- STATE


type Viewer
    = Viewer Internal


type alias Internal =
    { hexArchAuthToken : HexArchApi.AuthToken
    }



-- OUTPUT


hexArchAuthToken : Viewer -> HexArchApi.AuthToken
hexArchAuthToken (Viewer viewer) =
    viewer.hexArchAuthToken



-- JS PORTS


port viewerOutgoingMessage : Maybe Encode.Value -> Cmd msg


port viewerIncomingMessage : (Encode.Value -> msg) -> Sub msg


store : Viewer -> Cmd msg
store viewer =
    viewerOutgoingMessage (Just (encode viewer))


clear : Cmd msg
clear =
    viewerOutgoingMessage Nothing


onChangeFromOtherTab : (Result Decode.Error Viewer -> msg) -> Sub msg
onChangeFromOtherTab tagger =
    viewerIncomingMessage (tagger << Decode.decodeValue decoder)



-- ENCODE / DECODE


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
