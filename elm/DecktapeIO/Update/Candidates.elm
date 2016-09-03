-- Functions for fetching candidates from the server


module DecktapeIO.Update.Candidates exposing (..)

import DecktapeIO.Msg exposing (..)
import DecktapeIO.Model exposing (URL)
import DecktapeIO.Update.Json exposing (outputDecoder)
import Platform.Cmd exposing (Cmd)
import Http
import Json.Decode
import Task


-- Given a URL, this requests matching candidates from the server.
-- Ultimately this results in an `UpdateCandidates` action.


getCandidates : URL -> Cmd Msg
getCandidates source_url =
    let
        url =
            Http.url "/candidates" [ ( "url", source_url ) ]
        task =
            Http.get (Json.Decode.list outputDecoder) url
    in
        Task.perform
            (\x -> UpdateCandidates source_url [])
            (\candidates -> UpdateCandidates source_url candidates)
            task
