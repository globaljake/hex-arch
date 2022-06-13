module Ui.PageView exposing (Layout(..), PageView, make, map, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Route exposing (Route)
import Ui.SidebarNav as SidebarNav



-- TYPES


type PageView msg
    = PageView (Html msg)


type Layout msg
    = StandardWithSidebarNav { header : String, activeRoute : Maybe Route, viewServices : Html msg }
    | Blank



-- CONSTUCTOR


make : Html msg -> PageView msg
make content_ =
    PageView content_



-- PROPERTIES


content : PageView msg -> Html msg
content (PageView content_) =
    content_



-- OUTPUT


view : Layout msg -> PageView msg -> Html msg
view layout pageView =
    Html.main_
        [ Attributes.class "h-screen w-full" ]
        [ case layout of
            Blank ->
                Html.div [ Attributes.class "flex h-full w-full bg-gray-50" ]
                    [ content pageView
                    ]

            StandardWithSidebarNav { header, activeRoute, viewServices } ->
                Html.div [ Attributes.class "flex h-full" ]
                    [ SidebarNav.view activeRoute
                    , Html.div [ Attributes.class "relative flex flex-1" ]
                        [ viewStandardWithSidebarNav header pageView
                        , Html.div [ Attributes.class "absolute inset-0" ]
                            [ viewServices
                            ]
                        ]
                    ]
        ]


viewStandardWithSidebarNav : String -> PageView msg -> Html msg
viewStandardWithSidebarNav header pageView =
    Html.div [ Attributes.class "flex flex-col bg-gray-50 p-5 w-full" ]
        [ Html.span [ Attributes.class "flex font-bold text-4xl text-gray-800 mb-5" ] [ Html.text header ]
        , content pageView
        ]



-- FUNCTOR


map : (a -> b) -> PageView a -> PageView b
map f pageView =
    PageView (Html.map f (content pageView))
