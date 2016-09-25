module DecktapeIO.View exposing (view)

import DecktapeIO.Model
import DecktapeIO.Msg exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Html.Shorthand exposing (..)
import Bootstrap.Html exposing (..)


-- Display of a single conversion request status.


conversionDetailsToRow : DecktapeIO.Model.ConversionDetails -> Html Msg
conversionDetailsToRow status =
    case status of
        DecktapeIO.Model.Initiated _ ->
            text "Initiated"

        DecktapeIO.Model.InProgress _ ->
            text "In progress"

        DecktapeIO.Model.Complete data ->
            let
                filename =
                    data.locator.file_id ++ ".pdf"
            in
                a [ href data.download_url, downloadAs filename ] [ text "Download" ]

        DecktapeIO.Model.Error msg ->
            text msg



-- Display for the collection of URLs submitted for conversion.


submittedUrlsView : DecktapeIO.Model.Model -> Html Msg
submittedUrlsView model =
    let
        make_row =
            (\conversion ->
                tr_
                    [ td_
                        [ a [ href conversion.source_url ]
                            [ text conversion.source_url ]
                        ]
                    , td_ [ conversionDetailsToRow conversion.details ]
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
                    , td_ [ text cand.timestamp ]
                    , td_ [ a [ href cand.download_url, downloadAs (cand.file_id ++ ".pdf") ] [ text "Download" ] ]
                    ]
            )

        sorted =
            model.candidates |> List.sortBy (\r -> r.timestamp) |> List.reverse

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
    div [ class "row" ]
        [ div [ class "col-md-12" ]
            [ div [ class "input-group" ]
                [ input
                    [ type' "text"
                    , class "form-control"
                    , value model.current_url
                    , placeholder "URL of HTML presentation, e.g. http://www.w3.org/Talks/Tools/Slidy"
                    , onInput SetCurrentUrl
                    ]
                    []
                , span
                    [ class "input-group-btn" ]
                    [ btnDefault' "input-control" { btnParam | label = Just "Convert!" } SubmitCurrentUrl ]
                ]
            ]
        ]


view : DecktapeIO.Model.Model -> Html Msg
view model =
    div []
        [ div [ class "well" ] [ mainForm model ]
        , row_
            [ colMd_ 6 6 6 [ submittedUrlsView model ]
            , colMd_ 6 6 6 [ candidatesView model ]
            ]
        ]
