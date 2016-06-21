module DecktapeIO (..) where

import Effects
import Html
import Html exposing (div, fromElement, Html, hr, h1, node, text)
import Html.Attributes exposing (href, rel, src)
import StartApp
import Task
import Bootstrap.Html exposing (..)
import Effects exposing (Effects)


type alias Model =
  { url : String
  }


noFx : model -> ( model, Effects a )
noFx model =
  ( model, Effects.none )


initialModel : Model
initialModel =
  { url = "http://something.example.com" }


type Action
  = Something
  | SomethingElse


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Something ->
      model |> noFx

    SomethingElse ->
      model |> noFx


stylesheet : String -> Html
stylesheet url =
  node "link" [ rel "stylesheet", href url ] []


script : String -> Html
script url =
  node "script" [ src url ] []


view : Signal.Address Action -> Model -> Html
view address model =
  containerFluid_
    [ stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
    , stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css"
    , script "https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"
    , script "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"
    , row_
        [ colMd_
            4
            4
            4
            ([ h1 [] [ text model.url ] ])
        ]
    ]


app : StartApp.App Model
app =
  StartApp.start
    { init = noFx initialModel
    , view = view
    , update = update
    , inputs = []
    }


main : Signal Html.Html
main =
  app.html


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
