port module Adapter exposing
    ( primarySessionAdapterSendMessage, primarySessionAdapterMessageReceiver, secondarySessionAdapterSendMessage, secondarySessionAdapterMessageReceiver
    , primaryModalAdapterSendMessage, primaryModalAdapterMessageReceiver
    , primaryToastAdapterSendMessage, primaryToastAdapterMessageReceiver
    , secondaryThingFormAdapterSendMessage, secondaryThingFormAdapterMessageReceiver
    )

{-| Hexagonal Architecture Adapters


# Session

@docs primarySessionAdapterSendMessage, primarySessionAdapterMessageReceiver, secondarySessionAdapterSendMessage, secondarySessionAdapterMessageReceiver


# Modal

@docs primaryModalAdapterSendMessage, primaryModalAdapterMessageReceiver


# Toast

@docs primaryToastAdapterSendMessage, primaryToastAdapterMessageReceiver


# ThingForm

@docs secondaryThingFormAdapterSendMessage, secondaryThingFormAdapterMessageReceiver

-}

import Json.Encode as Encode



-- PRIMARY / DRIVING ADAPTERS
-- Session


port primarySessionAdapterSendMessage : Encode.Value -> Cmd msg


port primarySessionAdapterMessageReceiver : (Encode.Value -> msg) -> Sub msg



-- Modal


port primaryModalAdapterSendMessage : Encode.Value -> Cmd msg


port primaryModalAdapterMessageReceiver : (Encode.Value -> msg) -> Sub msg



-- Toast


port primaryToastAdapterSendMessage : Encode.Value -> Cmd msg


port primaryToastAdapterMessageReceiver : (Encode.Value -> msg) -> Sub msg



-- SECONDARY / DRIVEN ADAPTERS
-- Session


port secondarySessionAdapterSendMessage : Encode.Value -> Cmd msg


port secondarySessionAdapterMessageReceiver : (Encode.Value -> msg) -> Sub msg



-- ThingForm


port secondaryThingFormAdapterSendMessage : Encode.Value -> Cmd msg


port secondaryThingFormAdapterMessageReceiver : (Encode.Value -> msg) -> Sub msg
