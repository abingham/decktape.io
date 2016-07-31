module DecktapeIO.Update (update) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (Model, Path, URL)
import Effects
import Http
import Json.Decode
import Json.Decode exposing ((:=))
import Http.Extra exposing (jsonReader, post, send, stringReader)
import Effects exposing (Effects)
import Task

conversionResponseDecoder : Json.Decode.Decoder Path
conversionResponseDecoder =
    ("path" := Json.Decode.string)

submitUrl : URL -> Effects Action
submitUrl presentationUrl =
    let
        url =
            Http.url "/convert" [("url", presentationUrl)]
        reader = jsonReader conversionResponseDecoder
        task = post url |> send reader stringReader
    in
        task
            |> Task.toResult
            |> Task.map ConversionResults
            |> Effects.task


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
  case action of
    SetUrl url ->
      { model | url = url } |> noFx

    SubmitUrl url ->
      ({ model | submittedUrls = ((url, "") :: model.submittedUrls) },
       submitUrl url)

    ConversionResults path ->
        model |> noFx
