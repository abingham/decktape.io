module DecktapeIO.Update.Submission (..) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Model exposing (..)
import DecktapeIO.Update.Json exposing (..)
import Effects
import Effects exposing (Effects)
import Json.Encode
import Http
import Http.Extra exposing (..)
import Result
import Task


-- Process the result of submitting a URL for conversion.
--
-- This results in a `HandleCompletion` action which will be handled
-- separately.

errorToString : Error String -> String
errorToString err =
    case err of
        UnexpectedPayload msg -> msg
        NetworkError -> "Network error"
        Timeout -> "Timeout"
        BadResponse r -> r.statusText

handleSubmissionResults : URL -> Result.Result (Error String) (Response DecktapeIO.Model.Output) -> DecktapeIO.Actions.Action
handleSubmissionResults source_url result =
    let
        r =
            case result of
                Result.Ok output ->
                    Result.Ok output.data

                Result.Err error ->
                    -- TODO: Handle the various flavors of error: UnexpectedPayload, NetworkError, etc.
                    Result.Err (errorToString error)
    in
        HandleCompletion source_url r



-- Submit a request to convert the presentation at `presentationUrl`.


submitUrl : URL -> Effects Action
submitUrl presentationUrl =
    let
        url =
            Http.url "/convert" []

        reader =
            jsonReader outputDecoder

        bodyObj =
            Json.Encode.object [ ( "url", Json.Encode.string presentationUrl ) ]

        body =
            (Http.string (Json.Encode.encode 2 bodyObj))

        task =
            post url
                |> withBody body
                |> withHeader "Content-type" "application/json"
                |> send reader stringReader
    in
        task
            |> Task.toResult
            |> Task.map (handleSubmissionResults presentationUrl)
            |> Effects.task
