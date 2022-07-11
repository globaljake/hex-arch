module Ui.Nav exposing (Nav, make, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Route exposing (Route)



-- STATE


type Nav
    = Nav (Maybe Route)



-- INITIAL STATE


make : Maybe Route -> Nav
make =
    Nav



-- OUTPUT


view : Nav -> Html msg
view (Nav maybeActive) =
    Html.div [ Attributes.class "flex flex-col justify-between w-56 shadow bg-white" ]
        [ Html.div [ Attributes.class "w-full" ]
            [ viewLogo
            , viewItems maybeActive
            ]
        , Html.div []
            [ Html.a [ Route.href Route.Logout, Attributes.class "flex group p-4 relative w-full" ]
                [ Html.span [ Attributes.class "text-gray-600 group-hover:text-red-500" ]
                    [ Html.span [ Attributes.class "ml-3 flex items-center" ]
                        [ Html.span [ Attributes.class "mr-2 text-sm" ] [ Html.i [ Attributes.class "fa-sign-out-alt fa-solid" ] [] ]
                        , Html.span [ Attributes.class "font-bold" ] [ Html.text "Logout" ]
                        ]
                    ]
                ]
            ]
        ]


viewLogo : Html msg
viewLogo =
    Html.div [ Attributes.class "flex justify-center items-center py-4 border-b border-gray-200 pointer-events-none" ]
        [ Html.img [ Attributes.class "w-40", Attributes.src "images/hex-arch-logo.png" ] []
        ]


viewItems : Maybe Route -> Html msg
viewItems active =
    Html.div [ Attributes.class "flex flex-col" ]
        (List.map (viewItem active)
            [ { route = Just Route.Dashboard, text = "Dashboard", icon = "fa-hospital fa-solid" }
            , { route = Nothing, text = "Clients/Patients", icon = "fa-user fa-solid" }
            , { route = Nothing, text = "Schedule", icon = "fa-calendar-alt fa-solid" }
            , { route = Nothing, text = "Invoices", icon = "fa-file-invoice-dollar fa-solid" }
            , { route = Nothing, text = "Tasks", icon = "fa-tasks fa-solid" }
            , { route = Just Route.Profile, text = "Profile", icon = "fa-file-medical fa-solid" }
            , { route = Nothing, text = "Reminders", icon = "fa-bell fa-solid" }
            , { route = Nothing, text = "Whiteboard", icon = "fa-chalkboard fa-solid" }
            ]
        )


viewItem : Maybe Route -> { route : Maybe Route, text : String, icon : String } -> Html msg
viewItem active config =
    let
        viewIconAndText icon text =
            Html.span [ Attributes.class "ml-3 flex items-center" ]
                [ Html.span [ Attributes.class "mr-2 text-sm" ] [ Html.i [ Attributes.class icon ] [] ]
                , Html.span [ Attributes.class "font-bold" ] [ Html.text text ]
                ]
    in
    case ( config.route, active == config.route ) of
        ( Nothing, _ ) ->
            Html.span [ Attributes.class "p-4 pointer-events-none" ]
                [ Html.span [ Attributes.class "flex w-full justify-between" ]
                    [ Html.span [ Attributes.class "text-gray-600" ]
                        [ viewIconAndText config.icon config.text
                        ]
                    ]
                ]

        ( Just route, True ) ->
            Html.span [ Attributes.class "bg-blue-50 p-4 relative pointer-events-none" ]
                [ Html.span [ Attributes.class "flex absolute inset-0 h-full w-1 bg-blue-500 opacity-100" ] []
                , Html.span [ Attributes.class "flex w-full justify-between" ]
                    [ Html.span [ Attributes.class "text-blue-500" ]
                        [ viewIconAndText config.icon config.text
                        ]
                    ]
                ]

        ( Just route, False ) ->
            Html.a [ Route.href route, Attributes.class "hover:bg-blue-50 group p-4 relative" ]
                [ Html.span
                    [ Attributes.class "flex absolute inset-0 h-full w-1 bg-blue-500 group-hover:opacity-100 opacity-0"
                    ]
                    []
                , Html.span [ Attributes.class "text-gray-600 group-hover:text-blue-500" ]
                    [ viewIconAndText config.icon config.text
                    ]
                ]
