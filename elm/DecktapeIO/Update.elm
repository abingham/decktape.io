module DecktapeIO.Update (update) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (Model)
import Effects


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
  case action of
    SetUrl url ->
      { model | url = url } |> noFx

    SubmitUrl url ->
      { model | submittedUrls = (url :: model.submittedUrls) } |> noFx
