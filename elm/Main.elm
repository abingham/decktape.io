module DecktapeIO (..) where

import DecktapeIO.App exposing (app)
import Html
import Task
import Effects exposing (Effects)


main : Signal Html.Html
main =
  app.html


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
