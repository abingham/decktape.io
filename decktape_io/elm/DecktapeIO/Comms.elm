-- Utilities for communicating with the server, reading its output, etc.


module DecktapeIO.Comms exposing (..)

import DecktapeIO.Model
import Json.Decode
import Json.Decode exposing ((:=))
import Http


-- Process the result of submitting a URL for conversion.
--
-- This results in a `HandleCompletion` action which will be handled
-- separately.


errorToString : Http.Error -> String
errorToString err =
    case err of
        Http.UnexpectedPayload msg ->
            msg

        Http.NetworkError ->
            "Network error"

        Http.Timeout ->
            "Timeout"

        Http.BadResponse i r ->
            r



-- Decodes the JSON response from a conversion request into an `Output`.

pendingConversionDecoder : Json.Decode.Decoder DecktapeIO.Model.PendingConversion
pendingConversionDecoder =
    Json.Decode.object2
        DecktapeIO.Model.PendingConversion
        ("file_id" := Json.Decode.string)
        ("status_url" := Json.Decode.string)
