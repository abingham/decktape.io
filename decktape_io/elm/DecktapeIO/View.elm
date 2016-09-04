module DecktapeIO.View exposing (view)

import DecktapeIO.Model
import DecktapeIO.Msg exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Html.Shorthand exposing (..)
import Bootstrap.Html exposing (..)


-- Display of a single conversion request status.


statusToRow : DecktapeIO.Model.Status -> Html Msg
statusToRow status =
    case status of
        DecktapeIO.Model.InProgress ->
            text "In progress"

        DecktapeIO.Model.Ok output ->
            let
                filename =
                    output.file_id ++ ".pdf"
            in
                a [ href output.result_url, downloadAs filename ] [ text "Download" ]

        DecktapeIO.Model.Err msg ->
            text msg



-- Display for the collection of URLs submitted for conversion.


submittedUrlsView : DecktapeIO.Model.Model -> Html Msg
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

        body =
            if (List.isEmpty rows) then
                (em [] [ text "No submissions" ])
            else
                tableStriped_
                    [ thead_
                        [ th' { class = "text-left" } [ text "Source URL" ]
                        , th' { class = "text-left" } [ text "Status" ]
                        ]
                    , tbody_ rows
                    ]
    in
        panelDefault_
            [ panelHeading_ [ strong [] [ text "Submissions" ] ]
            , panelBody_ [ body ]
            ]


candidatesView : DecktapeIO.Model.Model -> Html Msg
candidatesView model =
    let
        make_row =
            (\cand ->
                tr_
                    [ td_ [ text cand.source_url ]
                    , td_ [ text cand.info.timestamp ]
                    , td_ [ a [ href cand.info.result_url ] [ text "Download" ] ]
                    ]
            )

        sorted =
            model.candidates |> List.sortBy (\r -> r.info.timestamp) |> List.reverse

        rows =
            List.map make_row sorted

        body =
            if (List.isEmpty rows) then
                (em [] [ text "No candidates" ])
            else
                tableStriped_
                    [ thead_
                        [ th' { class = "text-left" } [ text "URL" ]
                        , th' { class = "text-left" } [ text "Timestamp" ]
                        , th' { class = "text-left" } [ text "Link" ]
                        ]
                    , tbody_ rows
                    ]
    in
        panelDefault_
            [ panelHeading_ [ strong [] [ text "Candidates" ] ]
            , panelBody_ [ body ]
            ]


mainForm : DecktapeIO.Model.Model -> Html Msg
mainForm model =
    row_
        [ colMd_ 10
            10
            10
            [ input
                [ type' "text"
                , class "form-control"
                , value model.current_url
                , placeholder "URL of HTML presentation, e.g. http://localhost:6543/static/shwr.me/index.html"
                , onInput SetCurrentUrl
                ]
                []
            ]
        , colMd_ 2
            2
            2
            [ btnPrimary' "" { btnParam | label = Just "Convert!" } SubmitCurrentUrl ]
        ]


view : DecktapeIO.Model.Model -> Html Msg
view model =
    containerFluid_
        ([ div [(class "well")] [mainForm model]
         , row_
            [ colMd_ 6 6 6 [ submittedUrlsView model ]
            , colMd_ 6 6 6 [ candidatesView model ]
            ]
         ]
        )
