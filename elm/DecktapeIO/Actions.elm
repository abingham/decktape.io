module DecktapeIO.Actions (..) where

import DecktapeIO.Model
import Result exposing (Result)
import Http.Extra exposing (Error, Response)


type Action
  = SetUrl DecktapeIO.Model.URL
  | SubmitUrl DecktapeIO.Model.URL
  | ConversionResults (Result (Error String) (Response DecktapeIO.Model.Result))
