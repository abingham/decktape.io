module DecktapeIO.Actions (..) where

import DecktapeIO.Model exposing (Output, URL)
import Result exposing (Result)

type Action
  = SetCurrentUrl URL
  | SubmitCurrentUrl
  | HandleCompletion URL (Result String Output)
