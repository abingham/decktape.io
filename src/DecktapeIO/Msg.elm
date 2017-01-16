module DecktapeIO.Msg exposing (..)

import TaskRepeater as TaskRepeater
import DecktapeIO.Types exposing (..)
import Material


type Msg
    = SetCurrentUrl URL
    | SubmitCurrentUrl
    | SubmissionResult URL (Result String StatusLocator)
    | StatusResult FileID (Result String ConversionDetails)
    | Suggestions URL (Result String (List Suggestion))
    | Mdl (Material.Msg Msg)
    | Poll FileID (TaskRepeater.Msg Msg)
