module Toast exposing (Toast)

import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



-- STATE


type Toast
    = Toast (List Variant)


type Variant
    = Hey
    | LookAtMe
    | ImAToast



-- empty : Toast
-- empty =
--     Toast []
-- init : Variant -> ( Toast, Cmd Msg )
-- init variant =
--     ( Toast [], Cmd.none )
-- -- INPUT
-- type Msg
--     = GotInstruction (Result Decode.Error (Port.Instruction Variant))
-- -- TRANSITION
-- update : Msg -> Toast -> ( Toast, Cmd Msg )
-- update msg (Toast toastConfigs) =
--     Tuple.mapFirst Toast <|
--         case msg of
--             GotInstruction (Ok instruction) ->
--                 updateInstruction instruction toastConfigs
--             GotInstruction (Err err) ->
--                 ( toastConfigs, Cmd.none )
-- updateInstruction : Port.Instruction Variant -> List Variant -> ( List Variant, Cmd Msg )
-- updateInstruction instruction toastConfigs =
--     case instruction of
--         Port.Add toast ->
--             ( toast :: toastConfigs, Cmd.none )
--         Port.Remove toast ->
--             ( List.filter ((/=) toast) toastConfigs, Cmd.none )
--         Port.Clear ->
--             ( [], Cmd.none )
-- -- OUTPUT
-- view : Toast -> Html Msg
-- view (Toast variants) =
--     Html.div [ Attributes.class "flex flex-col space-y-4" ] (List.map viewToast variants)
-- viewToast : Variant -> Html msg
-- viewToast variant =
--     case variant of
--         Hey ->
--             viewToastItem { title = "hey", description = "Wassuuupp man" }
--         LookAtMe ->
--             viewToastItem { title = "Look At Me", description = "YOOOOO" }
--         ImAToast ->
--             viewToastItem { title = "Im A Toast", description = "thats right!" }
-- viewToastItem : { title : String, description : String } -> Html msg
-- viewToastItem { title, description } =
--     Html.div [ Attributes.class "p-4 w-64 bg-gray-100" ]
--         [ Html.span [ Attributes.class "text-2xl text-black font-bold" ] [ Html.text title ]
--         , Html.span [ Attributes.class "text-gray-600" ] [ Html.text description ]
--         ]
-- PORTS
-- port toastSendMessage : Encode.Value -> Cmd msg
-- port toastMessageReceiver : (Encode.Value -> msg) -> Sub msg
-- add : Variant -> Cmd msg
-- add config =
--     toastSendMessage (Port.encodeInstruction encode (Port.Add config))
-- remove : Variant -> Cmd msg
-- remove config =
--     toastSendMessage (Port.encodeInstruction encode (Port.Remove config))
-- clear : Cmd msg
-- clear =
--     toastSendMessage (Port.encodeInstruction encode Port.Clear)
-- subscriptions : Toast -> Sub Msg
-- subscriptions toast =
--     toastMessageReceiver
--         (GotInstruction << Decode.decodeValue (Port.decoderInstruction decoder))
-- encode : Variant -> Encode.Value
-- encode config =
--     case config of
--         Hey ->
--             Encode.object [ ( "constructor", Encode.string "Hey" ) ]
--         LookAtMe ->
--             Encode.object [ ( "constructor", Encode.string "LookAtMe" ) ]
--         ImAToast ->
--             Encode.object [ ( "constructor", Encode.string "ImAToast" ) ]
-- decoder : Decode.Decoder Variant
-- decoder =
--     Decode.field "constructor" Decode.string
--         |> Decode.andThen
--             (\s ->
--                 case s of
--                     "Hey" ->
--                         Decode.succeed Hey
--                     "LookAtMe" ->
--                         Decode.succeed LookAtMe
--                     "ImAToast" ->
--                         Decode.succeed ImAToast
--                     _ ->
--                         Decode.fail "Not a type constructor for Toast.Toast"
--             )
