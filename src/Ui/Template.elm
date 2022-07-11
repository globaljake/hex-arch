module Ui.Template exposing (Content, Template, blank, content, mapContent, standard, toHtml, toTitle)

import Html exposing (Html)
import Html.Attributes as Attributes
import Ui.Header as Header exposing (Header)
import Ui.Nav as Nav exposing (Nav)



-- STATE


type Template msg
    = Template (Layout msg) (Content msg)


type Content msg
    = Content ( String, Html msg )


type Layout msg
    = Blank
    | Standard Nav (Header msg)


content : ( String, Html msg ) -> Content msg
content =
    Content


mapContent : (a -> b) -> Content a -> Content b
mapContent f (Content ( title, content_ )) =
    Content ( title, Html.map f content_ )



-- INITIAL STATE


blank : Content msg -> Template msg
blank content_ =
    Template Blank content_


standard : Nav -> Header msg -> Content msg -> Template msg
standard nav header content_ =
    Template (Standard nav header) content_



-- OUTPUT


toTitle : Template msg -> String
toTitle (Template _ (Content content_)) =
    Tuple.first content_


toHtml : Template msg -> Html msg
toHtml (Template layout (Content content_)) =
    Html.div [ Attributes.class "h-full w-full bg-gray-50" ]
        [ case layout of
            Blank ->
                Tuple.second content_

            Standard nav header ->
                Html.div [ Attributes.class "flex h-full" ]
                    [ Nav.view nav
                    , Html.div [ Attributes.class "flex flex-col bg-gray-50 p-5 w-full" ]
                        [ Header.view header
                        , Tuple.second content_
                        ]
                    ]
        ]
