module DecktapeIO.View exposing (view)

import DecktapeIO.Model
import DecktapeIO.Msg exposing (..)
import Html exposing (a, div, h1, Html, p, text)
import Html.Attributes exposing (..)


-- import Html.Events exposing (onInput)
-- import Html.Shorthand exposing (..)

import Material.Button as Button


-- import Material.Card as Card

import Material.Color as Color
import Material.Grid as Grid
import Material.Layout as Layout
import Material.List as List
import Material.Options as Options
import Material.Scheme
import Material.Table exposing (table, tbody, td, th, thead, tr)
import Material.Textfield as Textfield
import Material.Typography as Typography


simpleStyle : Options.Property c Msg -> String -> Html Msg
simpleStyle property msg =
    Options.styled p
        [ property ]
        [ text msg ]


title : String -> Html Msg
title =
    simpleStyle Typography.title


caption : String -> Html Msg
caption =
    simpleStyle Typography.caption


button : String -> Html Msg
button =
    simpleStyle Typography.button


fullWidth : List (Options.Style Msg)
fullWidth =
    [ Grid.size Grid.Desktop 12, Grid.size Grid.Tablet 8, Grid.size Grid.Phone 4 ]


halfWidth : List (Options.Style Msg)
halfWidth =
    [ Grid.size Grid.Desktop 6, Grid.size Grid.Tablet 4, Grid.size Grid.Phone 2 ]


quarterWidth : List (Options.Style Msg)
quarterWidth =
    [ Grid.size Grid.Desktop 3, Grid.size Grid.Tablet 2, Grid.size Grid.Phone 1 ]


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


submittedTableView : DecktapeIO.Model.Model -> Html Msg
submittedTableView model =
    let
        make_row conversion =
            tr
                []
                [ td
                    []
                    [ a
                        [ href conversion.source_url ]
                        [ text conversion.source_url ]
                    ]
                , td
                    []
                    [ conversionDetailsToRow conversion.details ]
                ]

        rows =
            List.map make_row model.conversions
    in
        table []
            [ thead []
                [ tr []
                    [ th [] [ text "Source URL" ]
                    , th [] [ text "Status" ]
                    ]
                ]
            , tbody [] rows
            ]


submittedView : DecktapeIO.Model.Model -> Html Msg
submittedView model =
    if (List.isEmpty model.conversions) then
        caption "No submissions"
    else
        submittedTableView model


candidatesListView : DecktapeIO.Model.Model -> Html Msg
candidatesListView model =
    let
        make_item cand =
            List.li
                [ List.withSubtitle ]
                [ List.content
                    []
                    [ text cand.source_url
                    , List.subtitle [] [ text cand.timestamp ]
                    ]
                , a [ href cand.download_url, downloadAs (cand.file_id ++ ".pdf") ] [ button "Download" ]
                ]

        items =
            List.map make_item model.candidates
    in
        List.ul
            []
            items


candidatesView : DecktapeIO.Model.Model -> Html Msg
candidatesView model =
    if (List.isEmpty model.candidates) then
        caption "No candidates available"
    else
        candidatesListView model


urlForm : DecktapeIO.Model.Model -> Html Msg
urlForm model =
    div
        []
        [ Layout.row
            []
            [ Textfield.render Mdl
                [ 0 ]
                model.mdl
                [ Textfield.label "URL"
                , Textfield.floatingLabel
                , Textfield.value model.current_url
                , Textfield.onInput SetCurrentUrl
                ]
            ]
        , Layout.row
            []
            [ Button.render Mdl
                [ 0 ]
                model.mdl
                [ Button.raised
                , Button.ripple
                , Button.onClick SubmitCurrentUrl
                ]
                [ text "Convert" ]
            ]
        ]


viewBody : DecktapeIO.Model.Model -> Html Msg
viewBody model =
    div
        [ style [ ( "padding", "2rem" ) ] ]
        [ Grid.grid
            []
            [ Grid.cell fullWidth
                [ urlForm model ]
            , Grid.cell halfWidth
                [ title "Submissions"
                , submittedView model
                ]
            , Grid.cell halfWidth
                [ title "Candidates"
                , candidatesView model
                ]
            ]
        ]


view : DecktapeIO.Model.Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.BlueGrey Color.LightBlue <|
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
