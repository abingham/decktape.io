module DecktapeIO (..) where

import Effects
import Html
import Html exposing (div, fromElement, Html, hr, h1, input, label, node, text)
import Html.Attributes exposing (class, href, rel, src, type', value)
import Html.Events exposing (on, targetValue)
import StartApp
import Task
import Bootstrap.Html exposing (..)
import Effects exposing (Effects)


type alias Model =
  { url : String
  , submittedUrls : List String
  }


noFx : model -> ( model, Effects a )
noFx model =
  ( model, Effects.none )


initialModel : Model
initialModel =
  { url = "http://something.example.com"
    , submittedUrls = []
  }


type Action
  = SetUrl String
  | SubmitUrl String


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    SetUrl url ->
      { model | url = url } |> noFx

    SubmitUrl url ->
      { model | submittedUrls = (url :: model.submittedUrls) } |> noFx


stylesheet : String -> Html
stylesheet url =
  node "link" [ rel "stylesheet", href url ] []


script : String -> Html
script url =
  node "script" [ src url ] []

submittedUrlsView : Model -> List Html
submittedUrlsView model =
  List.map (\u -> row_ [ colMd_ 4 4 4 [ text u ] ]) model.submittedUrls

view : Signal.Address Action -> Model -> Html
view address model =
  containerFluid_
    ([ stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
    , stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css"
    , script "https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"
    , script "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"
    , row_
        [ colMd_
            4
            4
            4
            [ label [ class "control-label pull-right" ] [ text "URL:" ] ]
        , colMd_
            8
            8
            8
            [ input
                [ type' "text"
                , class "form-control"
                , value model.url
                , on "input" targetValue (Signal.message address << SetUrl)
                ]
                []
            ]
        ]
    , row_
        [ colMd_
            4
            4
            4
            [ btnDefault' "" { btnParam | label = Just "Convert!" } address (SubmitUrl model.url)
            ]
        ]
    ] ++ (submittedUrlsView model))


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
