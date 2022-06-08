module Page.NotFound exposing (view)

import Html exposing (Html)
import Ui.LayoutPage as LayoutPage exposing (LayoutPage)


view : LayoutPage msg
view =
    LayoutPage.constructor (Html.div [] [ Html.text "Not Found Yo" ])
