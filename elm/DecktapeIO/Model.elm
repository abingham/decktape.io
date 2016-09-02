module DecktapeIO.Model (..) where


type alias URL =
    String


type alias FileID =
    String



-- The results of a successful conversion.


type alias Output =
    { result_url : URL
    , file_id : FileID
    , timestamp : String
    }



-- The status of a conversion request, ongoing or completed.


type Status
    = InProgress
    | Ok Output
    | Err String



-- A single conversion, including source URL and current status.


type alias Conversion =
    { source_url : URL
    , status : Status
    }

type alias Candidate =
    { source_url : URL
    , info : Output
    }

-- The top-level application model.


type alias Model =
    { current_url : URL
    , conversions : List Conversion
    , candidates : List Candidate
    }



-- The initial model for the application.


initialModel : Model
initialModel =
    { current_url = "http://localhost:6543/static/shwr.me/index.html"
    , conversions = []
    , candidates = []
    }
