module Modal.BuyCoins exposing (Model, Msg, init, update, view)

import Html exposing (Html)



-- STATE


type Model
    = Model Internal


type alias Internal =
    {}


init : () -> ( Model, Cmd Msg )
init config =
    ( Model {}, Cmd.none )



-- INPUT


type Msg
    = NoOp



-- TRANSITION


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    Tuple.mapFirst Model <|
        case msg of
            NoOp ->
                ( model, Cmd.none )



-- OUTPUT


view : Model -> Html Msg
view model =
    Html.text "Buy Coins Modal"
