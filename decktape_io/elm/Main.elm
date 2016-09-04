module DecktapeIO exposing (..)

import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (initialModel, Model)
import DecktapeIO.Update exposing (update)
import DecktapeIO.View exposing (view)
import Html.App as Html

main : Program Never
main =
   Html.program
    { init = noFx initialModel
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }
