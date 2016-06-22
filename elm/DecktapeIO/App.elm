module DecktapeIO.App (app) where

import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (initialModel, Model)
import DecktapeIO.Update exposing (update)
import DecktapeIO.View exposing (view)
import StartApp

app : StartApp.App Model
app =
  StartApp.start
    { init = noFx initialModel
    , view = view
    , update = update
    , inputs = []
    }
