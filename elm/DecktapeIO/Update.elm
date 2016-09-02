module DecktapeIO.Update (update) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (..)
import DecktapeIO.Update.Candidates exposing (..)
import DecktapeIO.Update.Submission exposing (..)
import Effects
import Effects exposing (Effects)
import List.Extra exposing (replaceIf)
import Result


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

        UpdateCandidates url candidates ->
            { model | candidates = List.map (Candidate url) candidates } |> noFx
