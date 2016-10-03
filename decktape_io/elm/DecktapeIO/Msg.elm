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
    | CandidatesSuccess URL (List Candidate)
    | CandidatesError URL String
    | Mdl (Material.Msg Msg)
