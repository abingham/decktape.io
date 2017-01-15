module DecktapeIO.Msg exposing (..)

import TaskRepeater as TaskRepeater
import DecktapeIO.Types exposing (..)
import Material


type Msg
    = SetCurrentUrl URL
    | SubmitCurrentUrl
    | SubmissionSuccess URL StatusLocator
    | SubmissionError URL String
    | StatusSuccess FileID ConversionDetails
    | StatusError FileID String
    | SuggestionsSuccess URL (List Suggestion)
    | SuggestionsError URL String
    | Mdl (Material.Msg Msg)
    | Poll FileID (TaskRepeater.Msg Msg)
