module DecktapeIO.Update exposing (update)

import Cmd.Extra exposing (message)
import DecktapeIO.Comms exposing (..)
import DecktapeIO.Msg as Msg
import DecktapeIO.Model exposing (..)
import DecktapeIO.Polling as Polling
import DecktapeIO.Types as Types
import Dict
import List
import Material
import Monocle.Lens exposing (Lens)
import Result
import Return exposing (command, map, Return, singleton, zero)
import Return.Optics exposing (refractl)
import String
import TaskRepeater


inPlace : Lens a b -> (b -> b) -> a -> a
inPlace lens f model =
    let
        val = lens.get model |> f
    in
        lens.set val model


handleSubmissionSuccess : Types.StatusLocator -> Types.URL -> Return Msg.Msg Model -> Return Msg.Msg Model
handleSubmissionSuccess locator source_url =
    let
        conversion =
            Types.Conversion source_url (Types.Initiated locator)

        poller =
            Polling.statusPoller locator.status_url locator.file_id
    in
        map (inPlace conversions ((::) conversion))
            >> map (inPlace pollers (Dict.insert locator.file_id poller))
            >> command (TaskRepeater.start poller)


handleSubmissionError : String -> Types.URL -> Return Msg.Msg Model -> Return Msg.Msg Model
handleSubmissionError msg source_url =
    let
        conversion =
            Types.Conversion source_url (Types.Error msg)
    in
        map <| inPlace conversions ((::) conversion)


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


handleStatus_ : Bool -> Types.ConversionDetails -> Types.FileID -> Return Msg.Msg Model -> Return Msg.Msg Model
handleStatus_ removePoller details fileId =
    let
        conversionUpdater =
            updateDetails details fileId

        updatePollers p =
            if removePoller then
                Dict.remove fileId p
            else
                p
    in
        map (inPlace conversions (List.map conversionUpdater))
            >> map (inPlace pollers updatePollers)


handleStatusSuccess : Types.ConversionDetails -> Types.FileID -> Return Msg.Msg Model -> Return Msg.Msg Model
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


handleStatusError : String -> Types.FileID -> Return Msg.Msg Model -> Return Msg.Msg Model
handleStatusError =
    Types.Error >> handleStatus_ False


handleSetCurrentUrl : Types.URL -> Return Msg.Msg Model -> Return Msg.Msg Model
handleSetCurrentUrl url =
    map (current_url.set url)
        >> if String.length url < 5 then
            map (suggestions.set [])
           else
            command (getSuggestions url)


{-| Central update function.
-}
update : Msg.Msg -> Model -> Return Msg.Msg Model
update msg model =
    singleton model
        |> case msg of
            Msg.SetCurrentUrl url ->
                handleSetCurrentUrl url

            Msg.SubmitCurrentUrl ->
                command (message (Msg.SetCurrentUrl ""))
                    >> command (submitUrl model.current_url)

            Msg.SubmissionResult source_url (Ok locator) ->
                handleSubmissionSuccess locator source_url

            Msg.SubmissionResult source_url (Err msg) ->
                handleSubmissionError msg source_url

            Msg.StatusResult file_id (Ok details) ->
                handleStatusSuccess details file_id

            Msg.StatusResult file_id (Err msg) ->
                handleStatusError msg file_id

            Msg.Suggestions source_url (Ok suggs) ->
                map (suggestions.set suggs)

            Msg.Suggestions source_url (Err msg) ->
                zero

            Msg.Mdl msg' ->
                \( model, cmd ) -> Material.update msg' model

            Msg.Poll fileID msg ->
                refractl pollers identity <|
                    Polling.update fileID msg
