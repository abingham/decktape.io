module DecktapeIO.Msg exposing (..)

import DecktapeIO.Model exposing (..)
import Material


type Msg
    = SetCurrentUrl URL
    | SubmitCurrentUrl
    | ConversionSuccess URL StatusLocator
    | ConversionError URL String
    | StatusSuccess FileID ConversionDetails
    | StatusError FileID String
    | SuggestionsSuccess URL (List Suggestion)
    | SuggestionsError URL String
    | Mdl (Material.Msg Msg)
