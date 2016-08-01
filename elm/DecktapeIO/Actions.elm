module DecktapeIO.Actions (..) where

import DecktapeIO.Model exposing (ID, URL)
import Result exposing (Result)
import Http.Extra exposing (Error, Response)


type alias ConversionResponse =
  { url : URL
  , id : ID
  }


type Action
  = SetUrl URL
  | SubmitUrl URL
  | ConversionResults (Result (Error String) (Response ConversionResponse))
