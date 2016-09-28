module DecktapeIO.Msg exposing (..)

import DecktapeIO.Model exposing (..)
import Material
import Result exposing (Result)


type Msg
    = SetCurrentUrl URL
    | SubmitCurrentUrl
    | HandleConvertResponse URL (Result String StatusLocator)
    | HandleStatusResponse FileID (Result String ConversionDetails)
    | HandleCandidatesResponse URL (Result String (List Candidate))
    | Mdl (Material.Msg Msg)
