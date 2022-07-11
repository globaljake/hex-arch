module Ui.Header exposing (Header, make, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Ui.Button as Button
import Ui.Icon as Icon


type Header msg
    = Header String (Maybe msg)


make : String -> Maybe msg -> Header msg
make =
    Header


view : Header msg -> Html msg
view (Header heading maybeBackMsg) =
    Html.div [ Attributes.class "flex items-center mb-5" ]
        [ case maybeBackMsg of
            Just tagger ->
                Html.div [ Attributes.class "mr-2" ]
                    [ Button.asButton tagger <|
                        Button.make
                            { state = Button.Enabled
                            , style = Button.FilledWhite
                            , content = Button.Icon Icon.chevronLeft "Go Back"
                            }
                    ]

            Nothing ->
                Html.text ""
        , Html.span [ Attributes.class "flex font-bold text-4xl text-gray-800" ]
            [ Html.text heading
            ]
        ]
