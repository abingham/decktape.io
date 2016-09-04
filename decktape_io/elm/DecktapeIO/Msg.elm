module DecktapeIO.Msg exposing (..)

import DecktapeIO.Model exposing (Output, URL)
import Result exposing (Result)

type Msg
  = SetCurrentUrl URL
  | SubmitCurrentUrl
  | HandleCompletion URL (Result String Output)
  | UpdateCandidates URL (List Output)
