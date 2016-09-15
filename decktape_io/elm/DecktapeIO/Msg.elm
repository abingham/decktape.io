module DecktapeIO.Msg exposing (..)

import DecktapeIO.Model exposing (..)
import Result exposing (Result)

type Msg
  = SetCurrentUrl URL
  | SubmitCurrentUrl
  | HandleConvertResponse URL (Result String StatusLocator)
  | HandleStatusResponse FileID (Result String ConversionDetails)
  -- | HandleCompletion URL (Result String Output)
  -- | UpdateCandidates URL (List Output)
