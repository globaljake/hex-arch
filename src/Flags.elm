module Flags exposing (Flags, fromValue)

import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Viewer exposing (Viewer)



-- TYPE


type alias Flags =
    { viewer : Maybe Viewer }



-- VALUES


default : Flags
default =
    { viewer = Nothing }



-- ADAPTERS


fromValue : Encode.Value -> Flags
fromValue value =
    Decode.decodeValue decoder value
        |> Result.withDefault default


decoder : Decode.Decoder Flags
decoder =
    let
        viewerDecoder : Decode.Decoder (Maybe Viewer)
        viewerDecoder =
            Decode.string
                |> Decode.map
                    (\s ->
                        Decode.decodeString (Decode.maybe Viewer.decoder) s
                            |> Result.withDefault Nothing
                    )
    in
    Decode.succeed Flags
        |> Decode.required "viewer" viewerDecoder
