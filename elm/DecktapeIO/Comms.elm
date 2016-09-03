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


outputDecoder : Json.Decode.Decoder DecktapeIO.Model.Output
outputDecoder =
    Json.Decode.object3
        DecktapeIO.Model.Output
        ("result_url" := Json.Decode.string)
        ("file_id" := Json.Decode.string)
        ("timestamp" := Json.Decode.string)
