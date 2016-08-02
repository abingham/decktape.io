module DecktapeIO.Update (update) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model
import Effects
import Http
import Json.Encode
import Json.Decode
import Json.Decode exposing ((:=))
import Http.Extra exposing (jsonReader, post, send, stringReader, withBody, withHeader)
import Effects exposing (Effects)
import Task


resultDecoder : Json.Decode.Decoder DecktapeIO.Model.Result
resultDecoder =
  Json.Decode.object2
    (\s r -> { source_url = s, result_url = r })
    ("url" := Json.Decode.string)
    ("id" := Json.Decode.string)


submitUrl : DecktapeIO.Model.URL -> Effects Action
submitUrl presentationUrl =
  let
    url =
      Http.url "/convert" []

    reader =
      jsonReader resultDecoder

    bodyObj =
      Json.Encode.object [ ( "url", Json.Encode.string presentationUrl ) ]

    body =
      (Http.string (Json.Encode.encode 2 bodyObj))

    task =
      post url
        |> withBody body
        |> withHeader "Content-type" "application/json"
        |> send reader stringReader
  in
    task
      |> Task.toResult
      |> Task.map ConversionResults
      |> Effects.task


update : Action -> DecktapeIO.Model.Model -> ( DecktapeIO.Model.Model, Effects.Effects Action )
update action model =
  case action of
    SetUrl url ->
      { model | url = url } |> noFx

    SubmitUrl url ->
      ( { model | url = "" }
      , submitUrl url
      )

    ConversionResults result ->
      let
        newModel =
          case result of
            Ok response ->
              { model | results = response.data :: model.results }

            Err error ->
              -- TODO: Display results somewhere.
              model
      in
        newModel |> noFx
