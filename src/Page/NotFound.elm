module Page.NotFound exposing (view)

import Html exposing (Html)
import Ui.PageView as PageView exposing (PageView)


view : PageView msg
view =
    PageView.make (Html.div [] [ Html.text "Not Found Yo" ])
