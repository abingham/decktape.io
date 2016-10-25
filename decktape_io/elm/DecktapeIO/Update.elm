module DecktapeIO.Update exposing (update)

import DecktapeIO.Comms exposing (..)
import DecktapeIO.Msg as Msg
import DecktapeIO.Effects exposing (send)
import DecktapeIO.Model exposing (..)
import DecktapeIO.Polling as Polling
import DecktapeIO.Types as Types
import Dict
import List exposing (..)
import Material
import Result
import Return
import String
import TaskRepeater


handleSubmissionSuccess : Types.StatusLocator -> Model -> Types.URL -> Return.Return Msg.Msg Model
handleSubmissionSuccess locator model source_url =
    let
        conversion =
            Types.Conversion source_url (Types.Initiated locator)

        poller =
            Polling.statusPoller locator.file_id locator.status_url
    in
        Return.singleton model
            |> Return.map
                (\m ->
                    { m
                        | conversions = conversion :: m.conversions
                        , pollers = Dict.insert locator.file_id poller m.pollers
                    }
                )
            |> Return.command (TaskRepeater.start poller)


handleSubmissionError : String -> Model -> Types.URL -> Return.Return Msg.Msg Model
handleSubmissionError msg model source_url =
    let
        conversion =
            Types.Conversion source_url (Types.Error msg)
    in
        Return.singleton model
            |> Return.map (\m -> { m | conversions = conversion :: m.conversions })


statusDetails : Result String Types.ConversionDetails -> Types.ConversionDetails
statusDetails result =
    case result of
        Result.Err msg ->
            Types.Error msg

        Result.Ok details ->
            details


updateDetails : Types.ConversionDetails -> Types.FileID -> Types.Conversion -> Types.Conversion
updateDetails details file_id conv =
    let
        new_details =
            case conv.details of
                Types.Initiated locator ->
                    if locator.file_id == file_id then
                        details
                    else
                        conv.details

                Types.InProgress ipd ->
                    if ipd.locator.file_id == file_id then
                        details
                    else
                        conv.details

                Types.Complete cd ->
                    if cd.locator.file_id == file_id then
                        details
                    else
                        conv.details

                _ ->
                    conv.details
    in
        { conv | details = new_details }


handleStatus_ : Types.ConversionDetails -> Bool -> Types.FileID -> Model -> Return.Return Msg.Msg Model
handleStatus_ details removePoller fileId model =
    let
        updater =
            updateDetails details fileId

        conversions =
            List.map updater model.conversions

        pollers =
            if removePoller then
                Dict.remove fileId model.pollers
            else
                model.pollers
    in
        Return.singleton model
            |> Return.map
                (\m ->
                    { m
                        | conversions = conversions
                        , pollers = pollers
                    }
                )


handleStatusSuccess : Types.ConversionDetails -> Types.FileID -> Model -> Return.Return Msg.Msg Model
handleStatusSuccess details =
    let
        removePoller =
            case details of
                Types.Complete _ ->
                    True

                _ ->
                    False
    in
        handleStatus_ details removePoller


handleStatusError : String -> Types.FileID -> Model -> Return.Return Msg.Msg Model
handleStatusError msg =
    handleStatus_ (Types.Error msg) False


handleSetCurrentUrl : Model -> Types.URL -> Return.Return Msg.Msg Model
handleSetCurrentUrl model url =
    Return.singleton model
        |> Return.map (\m -> { m | current_url = url })
        |> if String.length url < 5 then
            Return.map (\m -> { m | suggestions = [] })
           else
            Return.command (getSuggestions url)


{-| Central update function.
-}
update : Msg.Msg -> Model -> Return.Return Msg.Msg Model
update msg model =
    case msg of
        Msg.SetCurrentUrl url ->
            handleSetCurrentUrl model url

        Msg.SubmitCurrentUrl ->
            Return.singleton model
                |> Return.map (\m -> { m | current_url = ""})
                |> Return.command (send (Msg.SetCurrentUrl ""))
                |> Return.command (submitUrl model.current_url)

        Msg.SubmissionSuccess source_url locator ->
            handleSubmissionSuccess locator model source_url

        Msg.SubmissionError source_url msg ->
            handleSubmissionError msg model source_url

        Msg.StatusSuccess file_id details ->
            handleStatusSuccess details file_id model

        Msg.StatusError file_id msg ->
            handleStatusError msg file_id model

        Msg.SuggestionsSuccess source_url suggestions ->
            Return.singleton model

        Msg.SuggestionsError source_url msg ->
            Return.singleton model

        Msg.Mdl msg' ->
            Material.update msg' model

        Msg.Poll fileID msg ->
            Polling.update model.pollers fileID msg
                |> Return.map (\p -> {model | pollers = p})
