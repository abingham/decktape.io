module DecktapeIO.Model (..) where

type alias URL = String
type alias Title = String

type Status
    = InProgress
    | Success URL Title
    | Error String


type alias Result =
  { source_url : URL
  , status : Status
  }

makeResult : URL -> Status -> Result
makeResult url status = { source_url = url, status = status }

type alias Model =
  { url : String
  , results : List Result
  }


initialModel : Model
initialModel =
  { url = "http://shwr.me/?full"
  , results = []
  }
