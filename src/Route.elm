module Route exposing (Route(..), back, fromUrl, href, replaceUrl)

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
    | Profile


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Dashboard Parser.top
        , Parser.map Login (Parser.s "login")
        , Parser.map Logout (Parser.s "logout")
        , Parser.map Profile (Parser.s "profile")
        ]


href : Route -> Attribute msg
href targetRoute =
    Attributes.href (toString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl navKey route =
    Nav.replaceUrl navKey (toString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


back : Nav.Key -> Cmd msg
back navKey =
    Nav.back navKey 1



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

        Profile ->
            ( [ "profile" ], [] )
