module DecktapeIO.Update exposing (update)

import DecktapeIO.Comms exposing (..)
import DecktapeIO.Msg exposing (..)
import DecktapeIO.Effects exposing (noFx, send)
import DecktapeIO.Model exposing (..)
import List exposing (..)
import Platform.Cmd exposing (batch, Cmd)
import Result
import String
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
                    getStatus (Time.second * 2) locator.file_id locator.status_url

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

        status_delay =
            Time.second * 10

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


handleCandidatesResponse : Model -> URL -> Result String (List Candidate) -> ( Model, Cmd Msg )
handleCandidatesResponse model source_url result =
    let
        model =
            case result of
                Result.Err msg ->
                    model

                Result.Ok cands ->
                    { model | candidates = cands }
    in
        model |> noFx


handleSetCurrentUrl : Model -> URL -> ( Model, Cmd Msg )
handleSetCurrentUrl model url =
    let
        new_model =
            { model | current_url = url }
    in
        if String.length url < 5 then
            { new_model | candidates = [] }
                |> noFx
        else
            ( new_model
            , getCandidates url
            )



-- Central update function.


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        SetCurrentUrl url ->
            handleSetCurrentUrl model url

        SubmitCurrentUrl ->
            ( { model | current_url = "" }
            , batch
                [ SetCurrentUrl "" |> send
                , submitUrl model.current_url
                ]
            )

        HandleConvertResponse source_url locator ->
            handleConvertResponse model source_url locator

        HandleStatusResponse file_id details ->
            handleStatusResponse model file_id details

        HandleCandidatesResponse source_url result ->
            handleCandidatesResponse model source_url result
