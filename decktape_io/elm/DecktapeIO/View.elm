module DecktapeIO.View exposing (view)

import DecktapeIO.Model
import DecktapeIO.Msg exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


-- import Html.Events exposing (onInput)
-- import Html.Shorthand exposing (..)

import Material.Button as Button


-- import Material.Card as Card

import Material.Color as Color
import Material.Grid as Grid
import Material.Layout as Layout
import Material.Scheme
import Material.Table as Table
import Material.Textfield as Textfield


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



-- -- Display for the collection of URLs submitted for conversion.
-- submittedUrlsView : DecktapeIO.Model.Model -> Html Msg
-- submittedUrlsView model =
--     let
--         make_row =
--             (\conversion ->
--                 tr_
--                     [ td_
--                         [ a [ href conversion.source_url ]
--                             [ text conversion.source_url ]
--                         ]
--                     , td_ [ conversionDetailsToRow conversion.details ]
--                     ]
--             )
--         rows =
--             List.map make_row model.conversions
--         body =
--             if (List.isEmpty rows) then
--                 (em [] [ text "No submissions" ])
--             else
--                 tableStriped_
--                     [ thead_
--                         [ th' { class = "text-left" } [ text "Source URL" ]
--                         , th' { class = "text-left" } [ text "Status" ]
--                         ]
--                     , tbody_ rows
--                     ]
--     in
--         panelDefault_
--             [ panelHeading_ [ strong [] [ text "Submissions" ] ]
--             , panelBody_ [ body ]
--             ]


submittedView : DecktapeIO.Model.Model -> Html Msg
submittedView model =
    let
        make_row conversion =
            Table.tr
                []
                [ Table.td
                    []
                    [ a
                        [ href conversion.source_url ]
                        [ text conversion.source_url ]
                    ]
                , Table.td
                    []
                    [ conversionDetailsToRow conversion.details ]
                ]

        rows =
            List.map make_row model.conversions
    in
        Table.table []
            [ Table.thead []
                [ Table.tr []
                    [ Table.th [] [ text "Source URL" ]
                    , Table.th [] [ text "Status" ]
                    ]
                ]
            , Table.tbody [] rows
            ]


candidatesView : DecktapeIO.Model.Model -> Html Msg
candidatesView model =
    let
        make_row cand =
            Table.tr []
                [ Table.td [] [ text cand.source_url ]
                , Table.td [] [ text cand.timestamp ]
                , Table.td [] [ a [ href cand.download_url, downloadAs (cand.file_id ++ ".pdf") ] [ text "Download" ] ]
                ]

        rows =
            List.map make_row model.candidates
    in
        Table.table []
            [ Table.thead []
                [ Table.tr []
                    [ Table.th [] [ text "URL" ]
                    , Table.th [] [ text "Timestamp" ]
                    , Table.th [] [ text "Link" ]
                    ]
                ]
            , Table.tbody [] rows
            ]



-- mainForm : DecktapeIO.Model.Model -> Html Msg
-- mainForm model =
--     div [ class "row" ]
--         [ div [ class "col-md-12" ]
--             [ div [ class "input-group" ]
--                 [ input
--                     [ type' "text"
--                     , class "form-control"
--                     , value model.current_url
--                     , placeholder "URL of HTML presentation, e.g. http://www.w3.org/Talks/Tools/Slidy"
--                     , onInput SetCurrentUrl
--                     ]
--                     []
--                 , span
--                     [ class "input-group-btn" ]
--                     [ btnDefault' "input-control" { btnParam | label = Just "Convert!" } SubmitCurrentUrl ]
--                 ]
--             ]
--         ]


urlForm : DecktapeIO.Model.Model -> Html Msg
urlForm model =
    div
        []
        [ Textfield.render Mdl
            [ 0 ]
            model.mdl
            [ Textfield.label "URL"
            , Textfield.floatingLabel
            , Textfield.value model.current_url
            , Textfield.onInput SetCurrentUrl
            ]
        , Button.render Mdl
            [ 0 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Button.onClick SubmitCurrentUrl
            ]
            [ text "Fetch new" ]
        ]


viewBody : DecktapeIO.Model.Model -> Html Msg
viewBody model =
    div
        [ style [ ( "padding", "2rem" ) ] ]
        [ Grid.grid
            []
            [ Grid.cell [ Grid.size Grid.Desktop 12, Grid.size Grid.Tablet 8, Grid.size Grid.Phone 4 ]
                [ urlForm model ]
            , Grid.cell [ Grid.size Grid.All 4 ]
                [ submittedView model ]
            , Grid.cell [ Grid.size Grid.All 4 ]
                [ candidatesView model ]
            ]
        ]


view : DecktapeIO.Model.Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Blue Color.LightBlue <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
              -- , Layout.selectedTab model.selectedTab
              -- , Layout.onSelectTab SelectTab
            ]
            { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "DeckTape.IO" ] ]
            , drawer =
                []
                -- , tabs = ( [ text "Milk", text "Oranges" ], [ Color.background (Color.color Color.Teal Color.S400) ] )
            , tabs = ( [], [] )
            , main = [ viewBody model ]
            }
