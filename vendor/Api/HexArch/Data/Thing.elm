module Api.HexArch.Data.Thing exposing (Thing, decoder, fetchAll, firstName, id, isActive, lastName)

import Api.HexArch.Api as Api
import Api.HexArch.Endpoint as Endpoint
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Task exposing (Task)



-- TYPES


type Thing
    = Thing Internal


type alias Internal =
    { id : String
    , firstName : String
    , lastName : String
    , isActive : Bool
    }



-- PROPERTIES


id : Thing -> String
id (Thing thing) =
    thing.id


firstName : Thing -> String
firstName (Thing thing) =
    thing.firstName


lastName : Thing -> String
lastName (Thing thing) =
    thing.lastName


isActive : Thing -> Bool
isActive (Thing thing) =
    thing.isActive



-- ADAPTERS


decoder : Decode.Decoder Thing
decoder =
    Decode.succeed Internal
        |> Decode.required "id" Decode.string
        |> Decode.optional "firstName" Decode.string "BAD FIRST NAME"
        |> Decode.optional "lastName" Decode.string "BAD LAST NAME"
        |> Decode.required "isInactive" Decode.bool
        |> Decode.map Thing



-- HTTP


fetchAll : Api.AuthToken -> Task Http.Error (List Thing)
fetchAll authToken =
    Api.get Endpoint.things (Just authToken) (Decode.field "value" (Decode.list decoder))
