module DecktapeIO.Update exposing (update)

import DecktapeIO.Comms exposing (..)
import DecktapeIO.Msg exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (..)
import Http
import Json.Decode
import Json.Encode
import List.Extra exposing (replaceIf)
import Platform.Cmd exposing (Cmd)
import Result
import Task


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



-- Central update function.


update : Msg -> Model -> ( Model, Cmd Msg )
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
