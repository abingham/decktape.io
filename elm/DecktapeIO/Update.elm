module DecktapeIO.Update (update) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (..)
import DecktapeIO.Update.Candidates exposing (..)
import DecktapeIO.Update.Json exposing (..)
import Effects
import Effects exposing (Effects)
import Json.Encode
import Http
import Http.Extra exposing (Error, get, jsonReader, post, Response, send, stringReader, withBody, withHeader)
import List.Extra exposing (replaceIf)
import Result
import Task

-- Process the result of submitting a URL for conversion.
--
-- This results in a `HandleCompletion` action which will be handled
-- separately.


handleSubmissionResults : URL -> Result.Result (Error String) (Response DecktapeIO.Model.Output) -> DecktapeIO.Actions.Action
handleSubmissionResults source_url result =
    let
        r =
            case result of
                Result.Ok output ->
                    Result.Ok output.data

                Result.Err error ->
                    -- TODO: Handle the various flavors of error: UnexpectedPayload, NetworkError, etc.
                    Result.Err "Something went wrong!"
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




-- Central update function.


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
    case action of
        SetCurrentUrl url ->
            ( { model | current_url = url }
            , getCandidates url
            )

        SubmitCurrentUrl ->
            let
                newConversion =
                    Conversion model.current_url InProgress
            in
                ( { model
                    | current_url = ""
                    , conversions = newConversion :: model.conversions
                  }
                , submitUrl model.current_url
                )

        HandleCompletion source_url result ->
            let
                status =
                    case result of
                        Result.Ok output ->
                            DecktapeIO.Model.Ok output

                        Result.Err msg ->
                            DecktapeIO.Model.Err msg

                new_conversion =
                    Conversion source_url status

                replacer =
                    replaceIf (\r -> r.source_url == source_url) new_conversion model.conversions
            in
                { model
                    | conversions = replacer
                }
                    |> noFx

        UpdateCandidates candidates ->
            { model | candidates = candidates } |> noFx
