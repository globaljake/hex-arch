module Http.Extra exposing (cgiParameters, formBody)

import Http
import String
import Url


cgiParameter : ( String, String ) -> String
cgiParameter ( key, value ) =
    Url.percentEncode key ++ "=" ++ Url.percentEncode value


cgiParameters : List ( String, String ) -> String
cgiParameters params =
    String.join "&" (List.map cgiParameter params)


formBody : List ( String, String ) -> Http.Body
formBody params =
    Http.stringBody "application/x-www-form-urlencoded" (cgiParameters params)
