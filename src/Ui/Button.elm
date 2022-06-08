module Ui.Button exposing (Button, Content(..), State(..), Style(..), asButton, asLink, asSubmit, make)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Ui.Icon as Icon exposing (Icon)



-- STATES


type Button
    = Button Internal


type alias Internal =
    { state : State
    , style : Style
    , content : Content
    }


type Intent route msg
    = Navigate (route -> Html.Attribute msg) route
    | OnClick msg
    | OnSubmit


type State
    = Enabled
    | Disabled
    | Loading


type Style
    = FilledPink
    | FilledBlue
    | FilledWhite


type Content
    = Text String
    | TextLarge String
    | Icon Icon String
    | IconWithText Icon String



-- INITIAL STATE


make : Internal -> Button
make =
    Button



-- OUTPUT


asLink : (route -> Html.Attribute msg) -> route -> Button -> Html msg
asLink toAttr route (Button { style, content, state }) =
    toElement state (Navigate toAttr route) (toAttributes state style) (toChild content)


asButton : msg -> Button -> Html msg
asButton tagger (Button { style, content, state }) =
    toElement state (OnClick tagger) (toAttributes state style) (toChild content)


asSubmit : Button -> Html msg
asSubmit (Button { style, content, state }) =
    toElement state OnSubmit (toAttributes state style) (toChild content)



-- INTERNAL


toElement : State -> Intent route msg -> List (Html.Attribute msg) -> Html Never -> Html msg
toElement state intent attrs child =
    case state of
        Enabled ->
            intentToElement intent attrs child

        Disabled ->
            Html.button attrs [ Html.map never child ]

        Loading ->
            Html.button attrs [ Html.map never (toChild (IconWithText Icon.spinner "Loading")) ]


toAttributes : State -> Style -> List (Html.Attribute msg)
toAttributes state style =
    case state of
        Enabled ->
            [ toClass style ]

        Disabled ->
            [ Attributes.disabled True, toClass style ]

        Loading ->
            [ Attributes.disabled True, toClass style ]


toClass : Style -> Html.Attribute msg
toClass style =
    Attributes.class <|
        case style of
            FilledPink ->
                buttonStyles "bg-pink-100 text-black "

            FilledBlue ->
                buttonStyles "bg-indigo-400 text-white"

            FilledWhite ->
                buttonStyles "bg-white text-black"



-- INTERNAL INTENT


intentToElement : Intent route msg -> List (Html.Attribute msg) -> Html Never -> Html msg
intentToElement intent attrs child =
    case intent of
        Navigate toAttr route ->
            Html.a (toAttr route :: attrs) [ Html.map never child ]

        OnClick msg ->
            Html.button (Events.onClick msg :: attrs) [ Html.map never child ]

        OnSubmit ->
            Html.button (Attributes.type_ "submit" :: attrs) [ Html.map never child ]



-- INTERNAL STYLE


buttonStyles : String -> String
buttonStyles classes =
    String.join " " [ styles, hoverStyles, focusStyles, disabledStyles, classes ]


styles : String
styles =
    "inline-flex w-full font-bold rounded-full transition duration-150 ease-in-out border-2 border-black text-center justify-center items-center"


hoverStyles : String
hoverStyles =
    "hover:shadow-md hover:-translate-x-1 hover:-translate-y-1"


focusStyles : String
focusStyles =
    "focus:shadow-md focus:-translate-x-1 focus:-translate-y-1 focus:outline-none"


disabledStyles : String
disabledStyles =
    "disabled:shadow-none disabled:translate-x-0 disabled:translate-y-0 disabled:opacity-60"



-- INTERNAL CONTENT


toChild : Content -> Html Never
toChild content =
    case content of
        Text text ->
            Html.span [ Attributes.class "flex px-4 py-2 text-sm" ] [ Html.text text ]

        TextLarge text ->
            Html.span [ Attributes.class "flex px-4 py-2 text-base" ] [ Html.text text ]

        Icon icon sr ->
            Html.span [ Attributes.class "flex p-2" ]
                [ Icon.view [ Icon.class "h-5 w-5" ] icon
                , Html.span [ Attributes.class "sr-only" ] [ Html.text sr ]
                ]

        IconWithText icon text ->
            Html.span [ Attributes.class "flex px-4 py-2 text-sm justify-center items-center" ]
                [ Icon.view [ Icon.class "h-4 w-4" ] icon
                , Html.span [ Attributes.class "ml-2" ] [ Html.text text ]
                ]
