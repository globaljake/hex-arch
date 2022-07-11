module Page.NotFound exposing (view)

import Html exposing (Html)
import Ui.Template as Template


view : Template.Content msg
view =
    Template.content ( "Not Found", Html.div [] [ Html.text "Not Found Yo" ] )
