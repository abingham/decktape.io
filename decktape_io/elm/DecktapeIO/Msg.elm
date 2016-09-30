module DecktapeIO.Msg exposing (..)

import DecktapeIO.Model exposing (..)
import Material
import Result exposing (Result)


type Msg
    = SetCurrentUrl URL
    | SubmitCurrentUrl
    | Conversion URL (Result String StatusLocator)
    | Status FileID (Result String ConversionDetails)
    | Candidates URL (Result String (List Candidate))
    | Mdl (Material.Msg Msg)
