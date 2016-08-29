module DecktapeIO.View (view) where

import DecktapeIO.Actions exposing (..)
import DecktapeIO.Model
import Html exposing (a, div, fromElement, Html, hr, h1, input, label, node, text)
import Html.Attributes exposing (class, downloadAs, href, rel, src, type', value)
import Html.Events exposing (on, targetValue)
import Html.Shorthand exposing (..)
import Bootstrap.Html exposing (..)


stylesheet : String -> Html
stylesheet url =
  node "link" [ rel "stylesheet", href url ] []


script : String -> Html
script url =
  node "script" [ src url ] []



-- Display of a single conversion request status.


statusToRow : DecktapeIO.Model.Status -> Html
statusToRow status =
  case status of
    DecktapeIO.Model.InProgress ->
      text "In progress"

    DecktapeIO.Model.Ok output ->
      let
        filename =
          output.title ++ ".pdf"
      in
        a [ href output.result_url, downloadAs filename ] [ text "Download" ]

    DecktapeIO.Model.Err msg ->
      text msg



-- Display for the collection of URLs submitted for conversion.


submittedUrlsView : DecktapeIO.Model.Model -> Html
submittedUrlsView model =
  let
    make_row =
      (\r ->
        tr_
          [ td_ [ a [ href r.source_url ] [ text r.source_url ] ]
          , td_ [ statusToRow r.status ]
          ]
      )

    rows =
      List.map make_row model.conversions
  in
    tableStriped_
      [ thead_
          [ th' { class = "text-left" } [ text "Source URL" ]
          , th' { class = "text-left" } [ text "Status" ]
          ]
      , tbody_ rows
      ]


view : Signal.Address Action -> DecktapeIO.Model.Model -> Html
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
                , value model.current_url
                , on "input" targetValue (Signal.message address << SetCurrentUrl)
                ]
                []
            ]
        ]
     , row_
        [ colMd_
            4
            4
            4
            [ btnDefault' "" { btnParam | label = Just "Convert!" } address (SubmitCurrentUrl)
            ]
        ]
     , submittedUrlsView model
     ]
    )
