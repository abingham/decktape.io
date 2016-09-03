module DecktapeIO.App exposing (app)

import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (initialModel, Model)
import DecktapeIO.Update exposing (update)
import DecktapeIO.View exposing (view)
import Html.App as Html

app : Program Never
app =
  Html.program
    { init = noFx initialModel
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }
