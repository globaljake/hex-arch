module Api.HexArch.Data.Thing exposing (Thing, decoder, encode, fetchAll, firstName, id, isActive, lastName, mock)

import Api.HexArch.Api as Api
import Api.HexArch.Endpoint as Endpoint
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
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


mock : Thing
mock =
    Thing
        { id = "1234"
        , firstName = "Jake"
        , lastName = "Quattrocchi"
        , isActive = True
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


encode : Thing -> Encode.Value
encode thing =
    Encode.object
        [ ( "id", Encode.string (id thing) )
        , ( "firstName", Encode.string (firstName thing) )
        , ( "lastName", Encode.string (lastName thing) )
        , ( "isActive", Encode.bool (isActive thing) )
        ]


decoder : Decode.Decoder Thing
decoder =
    Decode.succeed Internal
        |> Decode.required "id" Decode.string
        |> Decode.required "firstName" Decode.string
        |> Decode.required "lastName" Decode.string
        |> Decode.required "isActive" Decode.bool
        |> Decode.map Thing



-- HTTP


fetchAll : Api.AuthToken -> Task Http.Error (List Thing)
fetchAll authToken =
    Api.get Endpoint.things (Just authToken) (Decode.field "value" (Decode.list decoder))
