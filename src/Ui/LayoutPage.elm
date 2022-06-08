module Ui.LayoutPage exposing (Layout(..), LayoutPage, constructor, map, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Route exposing (Route)
import Ui.SidebarNav as SidebarNav



-- TYPES


type Layout msg
    = StandardWithSidebarNav { header : String, activeRoute : Maybe Route, viewServices : Html msg }
    | Blank


type LayoutPage msg
    = LayoutPage (Html msg)



-- CONSTUCTOR


constructor : Html msg -> LayoutPage msg
constructor content_ =
    LayoutPage content_



-- PROPERTIES


content : LayoutPage msg -> Html msg
content (LayoutPage content_) =
    content_



-- OUTPUT


view : Layout msg -> LayoutPage msg -> Html msg
view layout layoutPage =
    Html.main_
        [ Attributes.class "h-screen w-full" ]
        [ case layout of
            Blank ->
                Html.div [ Attributes.class "flex h-full w-full bg-gray-50" ]
                    [ content layoutPage
                    ]

            StandardWithSidebarNav { header, activeRoute, viewServices } ->
                Html.div [ Attributes.class "flex h-full" ]
                    [ SidebarNav.view activeRoute
                    , Html.div [ Attributes.class "relative flex flex-1" ]
                        [ viewStandardWithSidebarNav header layoutPage
                        , Html.div [ Attributes.class "absolute inset-0 bg-blue-200" ]
                            [ viewServices
                            ]
                        ]
                    ]
        ]


viewStandardWithSidebarNav : String -> LayoutPage msg -> Html msg
viewStandardWithSidebarNav header layoutPage =
    Html.div [ Attributes.class "flex flex-col bg-gray-50 p-5 w-full" ]
        [ Html.span [ Attributes.class "flex font-bold text-4xl text-gray-800 mb-5" ] [ Html.text header ]
        , content layoutPage
        ]



-- FUNCTOR


map : (a -> b) -> LayoutPage a -> LayoutPage b
map f layoutPage =
    LayoutPage (Html.map f (content layoutPage))
