module DecktapeIO.Model (..) where


type alias URL =
  String


type alias Title =
  String


-- The results of a successful conversion
type alias Output =
  { result_url : URL
  , title : Title
  }

-- The status of a request, ongoing or completed.
type Status
  = InProgress
  | Ok Output
  | Err String


-- A single conversion, including source URL and current status
type alias Conversion =
  { source_url : URL
  , status : Status
  }

type alias Model =
  { current_url : URL
  , conversions : List Conversion
  }


initialModel : Model
initialModel =
  { current_url = "http://shwr.me/?full"
  , conversions = []
  }
