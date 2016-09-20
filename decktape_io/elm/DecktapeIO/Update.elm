module DecktapeIO.Update exposing (update)

import DecktapeIO.Comms exposing (..)
import DecktapeIO.Msg exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (..)
import List exposing (..)
import Platform.Cmd exposing (Cmd)
import Result
import Time

handleConvertResponse : Model -> URL -> Result String StatusLocator -> ( Model, Cmd Msg )
handleConvertResponse model source_url result =
    let
        details =
            case result of
                Result.Err msg ->
                    Error msg

                Result.Ok locator ->
                    Initiated locator

        conversion =
            Conversion source_url details

        cmd =
            case result of
                Result.Ok locator ->
                    getStatus (Time.second * 10) locator.file_id locator.status_url

                _ ->
                    Platform.Cmd.none
    in
        ( { model
            | conversions = conversion :: model.conversions
          }
        , cmd
        )


statusDetails : Result String ConversionDetails -> ConversionDetails
statusDetails result =
    case result of
        Result.Err msg ->
            Error msg

        Result.Ok details ->
            details


updateDetails : ConversionDetails -> FileID -> Conversion -> Conversion
updateDetails details file_id conv =
    let
        new_details =
            case conv.details of
                Initiated locator ->
                    if locator.file_id == file_id then
                        details
                    else
                        conv.details

                InProgress ipd ->
                    if ipd.locator.file_id == file_id then
                        details
                    else
                        conv.details

                Complete cd ->
                    if cd.locator.file_id == file_id then
                        details
                    else
                        conv.details

                _ ->
                    conv.details
    in
        { conv | details = new_details }


handleStatusResponse : Model -> FileID -> Result String ConversionDetails -> ( Model, Cmd Msg )
handleStatusResponse model file_id result =
    let
        details =
            statusDetails result

        updater =
            updateDetails details file_id

        conversions =
            List.map updater model.conversions

        status_delay = Time.second * 10

        cmd =
            case details of
                Initiated locator ->
                    getStatus status_delay file_id locator.status_url

                InProgress ipd ->
                    getStatus status_delay file_id ipd.locator.status_url

                _ ->
                    Platform.Cmd.none
    in
        ( { model
            | conversions = conversions
          }
        , cmd
        )



-- getCandidates : URL -> Cmd Msg
-- getCandidates source_url =
--     let
--         url =
--             Http.url "/candidates" [ ( "url", source_url ) ]
--         task =
--             Http.get (Json.Decode.list outputDecoder) url
--     in
--         Task.perform
--             (\x -> UpdateCandidates source_url [])
--             (\candidates -> UpdateCandidates source_url candidates)
--             task
-- Central update function.


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        SetCurrentUrl url ->
            -- ( { model | current_url = url }
            -- , getCandidates url
            -- )
            { model | current_url = url } |> noFx

        SubmitCurrentUrl ->
            ( model
            , submitUrl model.current_url
            )

        HandleConvertResponse source_url locator ->
            handleConvertResponse model source_url locator

        HandleStatusResponse file_id details ->
            handleStatusResponse model file_id details



-- TODO: If conversion was successful, poll for results
-- HandleStatusResponse file_id result ->
--     model |> noFx
--  TODO: finish this
-- HandleCompletion source_url result ->
--     let
--         status =
--             case result of
--                 Result.Ok output ->
--                     DecktapeIO.Model.Ok output
--                 Result.Err msg ->
--                     DecktapeIO.Model.Err msg
--         new_conversion =
--             Conversion source_url status
--         replacer =
--             replaceIf (\r -> r.source_url == source_url) new_conversion model.conversions
--     in
--         { model
--             | conversions = replacer
--         }
--             |> noFx
-- UpdateCandidates url candidates ->
--     { model | candidates = List.map (Candidate url) candidates } |> noFx
