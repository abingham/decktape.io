module DecktapeIO.Actions (..) where

import DecktapeIO.Model exposing (Path, URL)
import Result exposing (Result)
import Http.Extra exposing (Error, Response)

type Action
  = SetUrl URL
  | SubmitUrl URL
  | ConversionResults (Result (Error String) (Response Path))
