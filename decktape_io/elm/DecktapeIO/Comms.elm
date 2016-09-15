-- Utilities for communicating with the server, reading its output, etc.


module DecktapeIO.Comms exposing (..)

import DecktapeIO.Model exposing (..)
import DecktapeIO.Msg exposing (..)
import Json.Decode
import Json.Decode exposing ((:=), andThen)
import Json.Encode
import Http
import Platform.Cmd exposing (Cmd)
import Task


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


convertDecoder : Json.Decode.Decoder DecktapeIO.Model.StatusLocator
convertDecoder =
    Json.Decode.object2
        DecktapeIO.Model.StatusLocator
        ("file_id" := Json.Decode.string)
        ("status_url" := Json.Decode.string)

-- statusCodeDecoder : Json.Decode.Decoder DecktapeIO.Model.StatusCode
-- statusCodeDecoder =
--     let
--         decode s =
--             case s of
--                 1 -> Result.Ok DecktapeIO.Model.InProgress
--                 2 -> Result.Ok DecktapeIO.Model.Complete
--                 3 -> Result.Ok DecktapeIO.Model.Error
--                 _ -> Result.Err "Can not convert value" -- TODO: include
--                                                         -- untranslatable value.
--     in
--         customDecoder (Json.Decode.int) decode



statusDecoder : URL -> Json.Decode.Decoder DecktapeIO.Model.ConversionDetails
statusDecoder status_url =
    ("status" := Json.Decode.int) `andThen` (conversionDetailsDecoder status_url)

conversionDetailsDecoder: URL -> Int -> Json.Decode.Decoder DecktapeIO.Model.ConversionDetails
conversionDetailsDecoder status_url status =
    case status of
        1 ->
            Json.Decode.object3
                (\ts msg fid ->
                     let
                         locator = StatusLocator fid status_url
                         details = InProgressDetails ts msg locator
                     in
                         InProgress details)
                ("timestamp" := Json.Decode.string)
                ("status_msg" := Json.Decode.string)
                ("file_id" := Json.Decode.string)

        2 ->
            Json.Decode.object3
                (\ts dl fid ->
                    let
                        locator = StatusLocator fid status_url
                        details = CompleteDetails locator ts dl
                    in
                        Complete details)
                ("timestamp" := Json.Decode.string)
                ("download_url" := Json.Decode.string)
                ("file_id" := Json.Decode.string)

        3 ->
            Json.Decode.object1
                Error
                ("status_msg" := Json.Decode.string)

        _ ->
            let
                msg = "Unknown status code: " ++ toString status
                details = Error msg
            in
                Json.Decode.succeed details



-- {"status_msg": "in progress", "status": 1, "file_id": "1c186f0a-7db5-11e6-8f7c-34363bc75ac6", "url": "w3.org/Talks/Tools/Slidy", "timestamp": "2016-09-18T17:32:29.529000"}

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
                convertDecoder
                url
                body
    in
        Task.perform
            (errorToString >> Result.Err >> HandleConvertResponse presentationUrl)
            (Result.Ok >> HandleConvertResponse presentationUrl)
            task


getStatus : FileID -> URL -> Platform.Cmd.Cmd Msg
getStatus file_id status_url =
    let
        url =
            Http.url status_url []

        task =
            Http.get
                (statusDecoder status_url)
                url
    in
        Task.perform
            (errorToString >> Result.Err >> HandleStatusResponse file_id)
            (Result.Ok >> HandleStatusResponse file_id)
            task



-- poll : FileID -> URL -> Platform.Cmd.Cmd Msg
-- poll file_id status_url =
