module DecktapeIO.Update exposing (update)

import DecktapeIO.Comms exposing (..)
import DecktapeIO.Msg exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (..)
import Http
import Json.Encode
import List exposing (..)
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
                pendingConversionDecoder
                url
                body
    in
        Task.perform
            (\err -> HandleConversionResponse presentationUrl (Result.Err (errorToString err)))
            (\response -> HandleConversionResponse presentationUrl (Result.Ok (PendingConversion response.file_id response.status_url)))
            task


handleConversionResponse : Model -> URL -> Result String PendingConversion -> Model
handleConversionResponse model source_url result =
    let
        conversion_status =
            case result of
                Result.Ok pending ->
                    InProgress pending

                Result.Err msg ->
                    DecktapeIO.Model.Err msg

        conversion = Conversion source_url conversion_status
    in
        { model
            | conversions = conversion :: model.conversions
        }



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

        HandleConversionResponse source_url result ->
            handleConversionResponse model source_url result |> noFx


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
