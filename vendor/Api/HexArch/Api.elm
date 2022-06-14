module Api.HexArch.Api exposing (AuthToken, authenticate, decoderAuthToken, delete, encodeAuthToken, get, post, put)

import Api.HexArch.Endpoint as Endpoint exposing (Endpoint)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Task exposing (Task)



-- STATE


type AuthToken
    = AuthToken String



-- OUTPUT


authTokenHeader : AuthToken -> Http.Header
authTokenHeader (AuthToken token) =
    Http.header "authorization" ("Bearer " ++ token)


encodeAuthToken : AuthToken -> Encode.Value
encodeAuthToken (AuthToken authToken) =
    Encode.string authToken


decoderAuthToken : Decode.Decoder AuthToken
decoderAuthToken =
    Decode.map AuthToken Decode.string



-- HTTP


get : Endpoint -> Maybe AuthToken -> Decode.Decoder a -> Task Http.Error a
get endpoint maybeAuthToken decoder =
    Endpoint.task
        { method = "GET"
        , headers =
            case maybeAuthToken of
                Just authToken ->
                    [ authTokenHeader authToken ]

                Nothing ->
                    []
        , endpoint = endpoint
        , body = Http.emptyBody
        , decoder = decoder
        , timeout = Nothing
        }


put : Endpoint -> AuthToken -> Http.Body -> Decode.Decoder a -> Task Http.Error a
put endpoint authToken body decoder =
    Endpoint.task
        { method = "PUT"
        , headers = [ authTokenHeader authToken ]
        , endpoint = endpoint
        , body = body
        , decoder = decoder
        , timeout = Nothing
        }


post : Endpoint -> Maybe AuthToken -> Http.Body -> Decode.Decoder a -> Task Http.Error a
post endpoint maybeAuthToken body decoder =
    Endpoint.task
        { method = "POST"
        , headers =
            case maybeAuthToken of
                Just authToken ->
                    [ authTokenHeader authToken ]

                Nothing ->
                    []
        , endpoint = endpoint
        , body = body
        , decoder = decoder
        , timeout = Nothing
        }


delete : Endpoint -> AuthToken -> Http.Body -> Decode.Decoder a -> Task Http.Error a
delete endpoint authToken body decoder =
    Endpoint.task
        { method = "DELETE"
        , headers = [ authTokenHeader authToken ]
        , endpoint = endpoint
        , body = body
        , decoder = decoder
        , timeout = Nothing
        }


authenticate : Http.Body -> Decode.Decoder (AuthToken -> viewer) -> Task Http.Error viewer
authenticate body decoderToViewer =
    let
        mock decoder =
            Task.succeed
                (Encode.object
                    [ ( "access_token", encodeAuthToken (AuthToken "__s_EcR_eTtOke_N_") )
                    ]
                )
                |> Task.andThen
                    (\value ->
                        case Decode.decodeValue decoder value of
                            Ok v ->
                                Task.succeed v

                            Err _ ->
                                Task.fail Http.NetworkError
                    )
    in
    Decode.field "access_token" decoderAuthToken
        |> Decode.map2 (\toViewer authToken -> toViewer authToken) decoderToViewer
        -- |> post Endpoint.authenticate Nothing body
        |> mock
