-- Functions for fetching candidates from the server


module DecktapeIO.Update.Candidates (..) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Model exposing (URL)
import DecktapeIO.Update.Json exposing (outputDecoder)
import Effects exposing (Effects)
import Http
import Http.Extra exposing (Error, get, jsonReader, post, Response, send, stringReader, withBody, withHeader)
import Json.Decode
import Result
import Task


-- Given a URL, this requests matching candidates from the server.
-- Ultimately this results in an `UpdateCandidates` action.


getCandidates : URL -> Effects Action
getCandidates source_url =
    let
        url =
            Http.url "/candidates" [ ( "url", source_url ) ]

        reader =
            jsonReader (Json.Decode.list outputDecoder)

        task =
            get url
                |> send reader stringReader
    in
        task
            |> Task.toResult
            |> Task.map (handleCandidates source_url)
            |> Effects.task



-- This handles the server's response to a request for candidates.


handleCandidates : URL -> Result.Result (Error String) (Response (List DecktapeIO.Model.Output)) -> DecktapeIO.Actions.Action
handleCandidates source_url result =
    case result of
        Result.Ok candidates ->
            UpdateCandidates source_url candidates.data

        Result.Err error ->
            UpdateCandidates source_url []
