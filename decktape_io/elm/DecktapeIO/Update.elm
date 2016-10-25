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
import Return.Optics exposing (refractl)
import String
import TaskRepeater


handleSubmissionSuccess : Types.StatusLocator -> Types.URL -> Return.Return Msg.Msg Model -> Return.Return Msg.Msg Model
handleSubmissionSuccess locator source_url =
    let
        conversion =
            Types.Conversion source_url (Types.Initiated locator)

        poller =
            Polling.statusPoller locator.file_id locator.status_url
    in
        Return.map
            (\m ->
                { m
                    | conversions = conversion :: m.conversions
                    , pollers = Dict.insert locator.file_id poller m.pollers
                }
            )
            >> Return.command (TaskRepeater.start poller)


handleSubmissionError : String -> Types.URL -> Return.Return Msg.Msg Model -> Return.Return Msg.Msg Model
handleSubmissionError msg source_url =
    let
        conversion =
            Types.Conversion source_url (Types.Error msg)
    in
        Return.map (\m -> { m | conversions = conversion :: m.conversions })


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


handleStatus_ : Bool -> Types.ConversionDetails -> Types.FileID -> Return.Return Msg.Msg Model -> Return.Return Msg.Msg Model
handleStatus_ removePoller details fileId =
    let
        updater =
            updateDetails details fileId

        pollers m =
            if removePoller then
                Dict.remove fileId m.pollers
            else
                m.pollers
    in
        Return.map
            (\m ->
                { m
                    | conversions = List.map updater m.conversions
                    , pollers = pollers m
                }
            )


handleStatusSuccess : Types.ConversionDetails -> Types.FileID -> Return.Return Msg.Msg Model -> Return.Return Msg.Msg Model
handleStatusSuccess details =
    let
        removePoller =
            case details of
                Types.Complete _ ->
                    True

                _ ->
                    False
    in
        handleStatus_ removePoller details


handleStatusError : String -> Types.FileID -> Return.Return Msg.Msg Model -> Return.Return Msg.Msg Model
handleStatusError =
    Types.Error >> handleStatus_ False


handleSetCurrentUrl : Types.URL -> Return.Return Msg.Msg Model -> Return.Return Msg.Msg Model
handleSetCurrentUrl url =
    Return.map (\m -> { m | current_url = url })
        >> if String.length url < 5 then
            Return.map (\m -> { m | suggestions = [] })
           else
            Return.command (getSuggestions url)


{-| Central update function.
-}
update : Msg.Msg -> Model -> Return.Return Msg.Msg Model
update msg model =
    Return.singleton model
        |> case msg of
            Msg.SetCurrentUrl url ->
                handleSetCurrentUrl url

            Msg.SubmitCurrentUrl ->
                Return.map (\m -> { m | current_url = "" })
                    >> Return.command (send (Msg.SetCurrentUrl ""))
                    >> Return.command (submitUrl model.current_url)

            Msg.SubmissionSuccess source_url locator ->
                handleSubmissionSuccess locator source_url

            Msg.SubmissionError source_url msg ->
                handleSubmissionError msg source_url

            Msg.StatusSuccess file_id details ->
                handleStatusSuccess details file_id

            Msg.StatusError file_id msg ->
                handleStatusError msg file_id

            Msg.SuggestionsSuccess source_url suggestions ->
                Return.map (\m -> {m | suggestions = suggestions})

            Msg.SuggestionsError source_url msg ->
                Return.zero

            Msg.Mdl msg' ->
                \(model, cmd) -> Material.update msg' model

            Msg.Poll fileID msg ->
                refractl pollers identity <|
                    Polling.update fileID msg
