module Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attributes
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), Parser)



-- ROUTING


type Route
    = Login
    | Logout
    | Dashboard
    | Forms


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Dashboard Parser.top
        , Parser.map Login (Parser.s "login")
        , Parser.map Logout (Parser.s "logout")
        , Parser.map Forms (Parser.s "forms")
        ]


href : Route -> Attribute msg
href targetRoute =
    Attributes.href (toString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url



-- INTERNAL


toString : Route -> String
toString route =
    let
        ( path, query ) =
            toPieces route
    in
    Builder.absolute path query


toPieces : Route -> ( List String, List Builder.QueryParameter )
toPieces page =
    case page of
        Dashboard ->
            ( [], [] )

        Login ->
            ( [ "login" ], [] )

        Logout ->
            ( [ "logout" ], [] )

        Forms ->
            ( [ "forms" ], [] )
