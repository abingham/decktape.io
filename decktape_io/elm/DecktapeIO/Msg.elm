module DecktapeIO.Msg exposing (..)

import DecktapeIO.Model exposing (PendingConversion, URL)
import Result exposing (Result)

type Msg
  = SetCurrentUrl URL
  | SubmitCurrentUrl
  | HandleConversionResponse URL (Result String PendingConversion)
  -- | HandleCompletion URL (Result String Output)
  -- | UpdateCandidates URL (List Output)
