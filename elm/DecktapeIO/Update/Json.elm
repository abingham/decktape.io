module DecktapeIO.Update.Json (..) where

import DecktapeIO.Model
import Json.Decode
import Json.Decode exposing ((:=))

-- Decodes the JSON response from a conversion request into an `Output`.


outputDecoder : Json.Decode.Decoder DecktapeIO.Model.Output
outputDecoder =
    Json.Decode.object3
        DecktapeIO.Model.Output
        ("result_url" := Json.Decode.string)
        ("file_id" := Json.Decode.string)
        ("timestamp" := Json.Decode.string)
