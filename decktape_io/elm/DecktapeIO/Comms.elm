-- Utilities for communicating with the server, reading its output, etc.


module DecktapeIO.Comms exposing (..)

import DecktapeIO.Model exposing (..)
import DecktapeIO.Msg as Msg
import Json.Decode exposing ((:=), andThen, Decoder, list, string, succeed)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Http
import Platform.Cmd exposing (Cmd)
import Process exposing (sleep)
import Task
import Time


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


suggestionDecoder : Decoder DecktapeIO.Model.Suggestion
suggestionDecoder =
    decode DecktapeIO.Model.Suggestion
        |> required "source_url" string
        |> required "download_url" string
        |> required "file_id" string
        |> required "timestamp" string



-- Decodes the JSON response from a conversion request into an `Output`.


convertDecoder : Decoder DecktapeIO.Model.StatusLocator
convertDecoder =
    decode DecktapeIO.Model.StatusLocator
        |> required "file_id" string
        |> required "status_url" string


statusDecoder : FileID -> URL -> Decoder DecktapeIO.Model.ConversionDetails
statusDecoder file_id status_url =
    ("status" := string) `andThen` (conversionDetailsDecoder file_id status_url)


conversionDetailsDecoder : FileID -> URL -> String -> Decoder DecktapeIO.Model.ConversionDetails
conversionDetailsDecoder file_id status_url status =
    case status of
        "in-progress" ->
            decode
                (\ts msg ->
                    let
                        locator =
                            StatusLocator file_id status_url

                        details =
                            InProgressDetails ts msg locator
                    in
                        InProgress details
                )
                |> required "timestamp" string
                |> required "status_msg" string

        "complete" ->
            decode
                (\ts dl ->
                    let
                        locator =
                            StatusLocator file_id status_url

                        details =
                            CompleteDetails locator ts dl
                    in
                        Complete details
                )
                |> required "timestamp" string
                |> required "download_url" string

        "error" ->
            decode Error
                |> required "status_msg" string

        _ ->
            let
                msg =
                    "Unknown status code: " ++ toString status

                details =
                    Error msg
            in
                succeed details



-- {"status_msg": "in progress", "status": 1, "file_id": "1c186f0a-7db5-11e6-8f7c-34363bc75ac6", "url": "w3.org/Talks/Tools/Slidy", "timestamp": "2016-09-18T17:32:29.529000"}


submitUrl : URL -> Platform.Cmd.Cmd Msg.Msg
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
                convertDecoder
                url
                body
    in
        Task.perform
            (errorToString >> Msg.ConversionError presentationUrl)
            (Msg.ConversionSuccess presentationUrl)
            task


getStatus : Time.Time -> FileID -> URL -> Platform.Cmd.Cmd Msg.Msg
getStatus after file_id status_url =
    let
        url =
            Http.url status_url []

        request =
            Http.get
                (statusDecoder file_id status_url)
                url

        task =
            Process.sleep after `Task.andThen` (\_ -> request)
    in
        Task.perform
            (errorToString >> Msg.StatusError file_id)
            (Msg.StatusSuccess file_id)
            task


getSuggestions : URL -> Cmd Msg.Msg
getSuggestions source_url =
    let
        url =
            Http.url "/suggestions" [ ( "url", source_url ) ]

        task =
            Http.get (list suggestionDecoder) url
    in
        Task.perform
            (errorToString >> Msg.SuggestionsError source_url)
            (Msg.SuggestionsSuccess source_url)
            task
