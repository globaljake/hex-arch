module Api.HexArch.Endpoint exposing (Endpoint, authenticate, task, things)

import Http
import Json.Decode as Decode
import Task exposing (Task)
import Url.Builder exposing (QueryParameter)



-- STATE


type Endpoint
    = Endpoint String



-- INITIAL STATE


authenticate : Endpoint
authenticate =
    url [ "authenticate" ] []


things : Endpoint
things =
    url [ "things" ] []



-- OUTPUT


endpoint : Endpoint -> String
endpoint (Endpoint str) =
    str



-- HTTP


task :
    { method : String
    , headers : List Http.Header
    , endpoint : Endpoint
    , body : Http.Body
    , decoder : Decode.Decoder a
    , timeout : Maybe Float
    }
    -> Task Http.Error a
task config =
    Http.task
        { method = config.method
        , headers = config.headers
        , url = endpoint config.endpoint
        , body = config.body
        , resolver = jsonResolver config.decoder
        , timeout = config.timeout
        }


jsonResolver : Decode.Decoder a -> Http.Resolver Http.Error a
jsonResolver decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadUrl_ badUrl ->
                    Err (Http.BadUrl badUrl)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata body ->
                    Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ _ body ->
                    case Decode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody (Decode.errorToString err))



-- INTERNAL


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Endpoint (Url.Builder.crossOrigin "https://api.myappdomain.com" ([ "api", "v1" ] ++ paths) queryParams)
