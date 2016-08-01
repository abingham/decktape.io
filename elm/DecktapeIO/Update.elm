module DecktapeIO.Update (update) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (Model, ID, URL)
import Effects
import Http
import Json.Encode
import Json.Decode
import Json.Decode exposing ((:=))
import Http.Extra exposing (jsonReader, post, send, stringReader, withBody, withHeader)
import Effects exposing (Effects)
import Task
import List


conversionResponseDecoder : Json.Decode.Decoder ConversionResponse
conversionResponseDecoder =
  let
    toResponse url id =
      { url = url
      , id = id
      }
  in
    Json.Decode.object2
      toResponse
      ("url" := Json.Decode.string)
      ("id" := Json.Decode.string)


submitUrl : URL -> Effects Action
submitUrl presentationUrl =
  let
    url =
      Http.url "/convert" []

    reader =
      jsonReader conversionResponseDecoder

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


applyConversionResult : List ( URL, ID ) -> ConversionResponse -> List ( URL, ID )
applyConversionResult model response =
  let
    f =
      response.url

    updateID ( u, p ) =
      if u == response.url then
        ( response.url, response.id )
      else
        ( u, p )
  in
    List.map updateID model


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
  case action of
    SetUrl url ->
      { model | url = url } |> noFx

    SubmitUrl url ->
      ( { model | submittedUrls = (( url, "" ) :: model.submittedUrls) }
      , submitUrl url
      )

    ConversionResults response ->
      case response of
        Ok r ->
          { model | submittedUrls = applyConversionResult model.submittedUrls r.data } |> noFx

        Err error ->
          -- TODO: Display results somewhere.
          model |> noFx
