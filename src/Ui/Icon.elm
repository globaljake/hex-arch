module Ui.Icon exposing
    ( Attribute
    , Icon
    , arrowUp
    , cash
    , chartPie
    , checkCircle
    , chevronLeft
    , class
    , classList
    , creditCard
    , exclamationCircle
    , externalLink
    , gear
    , grid
    , library
    , lightBulb
    , locationMarker
    , logout
    , pencil
    , plus
    , search
    , sparkles
    , spinner
    , star
    , sun
    , view
    , x
    )

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes as Attributes



-- ATTRIBUTES


type Attribute msg
    = Attribute (Svg.Attribute msg)


unattr : Attribute msg -> Svg.Attribute msg
unattr (Attribute attr) =
    attr


class : String -> Attribute msg
class =
    Attribute << Attributes.class


classList : List ( String, Bool ) -> Attribute msg
classList classes =
    List.filter Tuple.second classes
        |> List.map Tuple.first
        |> String.join " "
        |> class



-- ICONS


type Icon
    = Icon (List (Svg Never))


grid : Icon
grid =
    Icon
        [ Svg.path
            [ Attributes.d "M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"
            ]
            []
        ]


chartPie : Icon
chartPie =
    Icon
        [ Svg.path
            [ Attributes.d "M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z"
            ]
            []
        , Svg.path
            [ Attributes.d "M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z"
            ]
            []
        ]


gear : Icon
gear =
    Icon
        [ Svg.path
            [ Attributes.d "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
            ]
            []
        , Svg.path
            [ Attributes.d "M15 12a3 3 0 11-6 0 3 3 0 016 0z"
            ]
            []
        ]


lightBulb : Icon
lightBulb =
    Icon
        [ Svg.path
            [ Attributes.d "M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
            ]
            []
        ]


search : Icon
search =
    Icon
        [ Svg.path
            [ Attributes.d "M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            ]
            []
        ]


x : Icon
x =
    Icon
        [ Svg.path
            [ Attributes.d "M6 18L18 6M6 6l12 12"
            ]
            []
        ]


star : Icon
star =
    Icon
        [ Svg.path
            [ Attributes.d "M11.049 2.927C11.349 2.006 12.652 2.006 12.951 2.927L14.47 7.601C14.5354 7.80149 14.6625 7.97618 14.8331 8.1001C15.0037 8.22403 15.2091 8.29085 15.42 8.291H20.335C21.304 8.291 21.706 9.531 20.923 10.101L16.947 12.989C16.7762 13.1132 16.6491 13.2882 16.5839 13.489C16.5187 13.6899 16.5187 13.9062 16.584 14.107L18.102 18.781C18.402 19.703 17.347 20.469 16.564 19.899L12.588 17.011C12.4171 16.8868 12.2113 16.8199 12 16.8199C11.7887 16.8199 11.5829 16.8868 11.412 17.011L7.436 19.899C6.653 20.469 5.598 19.702 5.898 18.781L7.416 14.107C7.48128 13.9062 7.48132 13.6899 7.41611 13.489C7.3509 13.2882 7.22379 13.1132 7.053 12.989L3.077 10.101C2.293 9.531 2.697 8.291 3.665 8.291H8.579C8.79005 8.29106 8.9957 8.22434 9.16652 8.1004C9.33735 7.97646 9.46457 7.80165 9.53 7.601L11.049 2.927V2.927Z"
            ]
            []
        ]


logout : Icon
logout =
    Icon
        [ Svg.path
            [ Attributes.d "M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
            ]
            []
        ]


locationMarker : Icon
locationMarker =
    Icon
        [ Svg.path
            [ Attributes.d "M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
            ]
            []
        , Svg.path
            [ Attributes.d "M15 11a3 3 0 11-6 0 3 3 0 016 0z"
            ]
            []
        ]


chevronLeft : Icon
chevronLeft =
    Icon
        [ Svg.path
            [ Attributes.d "M15 19l-7-7 7-7"
            ]
            []
        ]


plus : Icon
plus =
    Icon
        [ Svg.path
            [ Attributes.d "M12 6v6m0 0v6m0-6h6m-6 0H6"
            ]
            []
        ]


sparkles : Icon
sparkles =
    Icon
        [ Svg.path
            [ Attributes.d "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"
            ]
            []
        ]


library : Icon
library =
    Icon
        [ Svg.path
            [ Attributes.d "M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z"
            ]
            []
        ]


sun : Icon
sun =
    Icon
        [ Svg.path
            [ Attributes.d "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
            ]
            []
        ]


arrowUp : Icon
arrowUp =
    Icon
        [ Svg.path
            [ Attributes.d "M5 10l7-7m0 0l7 7m-7-7v18"
            ]
            []
        ]


pencil : Icon
pencil =
    Icon
        [ Svg.path
            [ Attributes.d "M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
            ]
            []
        ]


cash : Icon
cash =
    Icon
        [ Svg.path
            [ Attributes.d "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"
            ]
            []
        ]


exclamationCircle : Icon
exclamationCircle =
    Icon
        [ Svg.path
            [ Attributes.d "M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            ]
            []
        ]


checkCircle : Icon
checkCircle =
    Icon
        [ Svg.path
            [ Attributes.d "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            ]
            []
        ]


externalLink : Icon
externalLink =
    Icon
        [ Svg.path
            [ Attributes.d "M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
            ]
            []
        ]


creditCard : Icon
creditCard =
    Icon
        [ Svg.path
            [ Attributes.d "M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"
            ]
            []
        ]


spinner : Icon
spinner =
    Icon
        [ Svg.path
            [ Attributes.d "M1.95652 12C1.95652 6.45314 6.45314 1.95652 12 1.95652C17.5469 1.95652 22.0435 6.45314 22.0435 12H23C23 5.92487 18.0751 1 12 1C5.92487 1 1 5.92487 1 12H1.95652Z"
            ]
            [ Svg.animateTransform
                [ Attributes.attributeName "transform"
                , Attributes.type_ "rotate"
                , Attributes.dur "1s"
                , Attributes.from "0 12 12"
                , Attributes.to "360 12 12"
                , Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]



-- TRANSFORM


view : List (Attribute msg) -> Icon -> Html msg
view attrs (Icon inner) =
    Svg.svg
        (List.concat
            [ List.map unattr attrs
            , [ Attributes.viewBox "0 0 24 24"
              , Attributes.fill "none"
              , Attributes.stroke "currentColor"
              , Attributes.strokeWidth "2"
              , Attributes.strokeLinecap "round"
              , Attributes.strokeLinejoin "round"
              ]
            ]
        )
        (List.map (Html.map never) inner)
