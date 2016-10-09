module DecktapeIO.Update exposing (update)

import DecktapeIO.Comms exposing (..)
import DecktapeIO.Msg as Msg
import DecktapeIO.Effects exposing (send)
import DecktapeIO.Model exposing (..)
import List exposing (..)
import Material
import Platform.Cmd exposing (batch, Cmd)
import Result
import String
import Time


handleConversion_ : ConversionDetails -> Cmd Msg.Msg -> Model -> URL -> ( Model, Cmd Msg.Msg )
handleConversion_ details cmd model source_url =
    let
        conversion =
            Conversion source_url details

        conversions =
            conversion :: model.conversions
    in
        { model | conversions = conversions } ! [ cmd ]


handleConversionSuccess : StatusLocator -> Model -> URL -> ( Model, Cmd Msg.Msg )
handleConversionSuccess locator =
    handleConversion_
        (Initiated locator)
        (getStatus (Time.second * 2) locator.file_id locator.status_url)


handleConversionError : String -> Model -> URL -> ( Model, Cmd Msg.Msg )
handleConversionError msg =
    handleConversion_ (Error msg) Platform.Cmd.none


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


handleStatus_ : ConversionDetails -> Cmd Msg.Msg -> FileID -> Model -> ( Model, Cmd Msg.Msg )
handleStatus_ details cmd file_id model =
    let
        updater =
            updateDetails details file_id

        conversions =
            List.map updater model.conversions
    in
        { model | conversions = conversions } ! [ cmd ]


handleStatusSuccess : ConversionDetails -> FileID -> Model -> ( Model, Cmd Msg.Msg )
handleStatusSuccess details file_id =
    let
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
        handleStatus_ details cmd file_id


handleStatusError : String -> FileID -> Model -> ( Model, Cmd Msg.Msg )
handleStatusError msg =
    handleStatus_ (Error msg) Platform.Cmd.none


handleSetCurrentUrl : Model -> URL -> ( Model, Cmd Msg.Msg )
handleSetCurrentUrl model url =
    let
        new_model =
            { model | current_url = url }
    in
        if String.length url < 5 then
            { new_model | suggestions = [] } ! []
        else
            new_model ! [ getSuggestions url ]



-- Central update function.


update : Msg.Msg -> Model -> ( Model, Cmd Msg.Msg )
update action model =
    case action of
        Msg.SetCurrentUrl url ->
            handleSetCurrentUrl model url

        Msg.SubmitCurrentUrl ->
            { model | current_url = "" }
                ! [ Msg.SetCurrentUrl "" |> send
                  , submitUrl model.current_url
                  ]

        Msg.ConversionSuccess source_url locator ->
            handleConversionSuccess locator model source_url

        Msg.ConversionError source_url msg ->
            handleConversionError msg model source_url

        Msg.StatusSuccess file_id details ->
            handleStatusSuccess details file_id model

        Msg.StatusError file_id msg ->
            handleStatusError msg file_id model

        Msg.SuggestionsSuccess source_url suggestions ->
            { model | suggestions = suggestions } ! []

        Msg.SuggestionsError source_url msg ->
            model ! []

        Msg.Mdl msg' ->
            Material.update msg' model
