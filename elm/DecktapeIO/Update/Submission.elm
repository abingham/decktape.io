module DecktapeIO.Update.Submission exposing (..)

import DecktapeIO.Msg exposing (..)
import DecktapeIO.Model exposing (..)
import DecktapeIO.Update.Json exposing (..)
import Platform.Cmd
import Json.Encode
import Http
import Result
import Task


-- Process the result of submitting a URL for conversion.
--
-- This results in a `HandleCompletion` action which will be handled
-- separately.

errorToString : Http.Error -> String
errorToString err =
    case err of
        Http.UnexpectedPayload msg -> msg
        Http.NetworkError -> "Network error"
        Http.Timeout -> "Timeout"
        Http.BadResponse i r -> r


-- Submit a request to convert the presentation at `presentationUrl`.


submitUrl : URL -> Platform.Cmd.Cmd Msg
submitUrl presentationUrl =
    let
        url =
            Http.url "/convert" []

        bodyObj =
            Json.Encode.object [ ( "url", Json.Encode.string presentationUrl ) ]

        body =
            (Http.string (Json.Encode.encode 2 bodyObj))

        task =
            Http.post
                outputDecoder
                url
                body
    in
        Task.perform
            (\err -> HandleCompletion presentationUrl (Result.Err (errorToString err)))
            (\output -> HandleCompletion presentationUrl (Result.Ok output))
            task
