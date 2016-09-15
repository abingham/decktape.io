module DecktapeIO.Model exposing (..)


type alias URL =
    String


type alias FileID =
    String



-- Response to a conversion request (i.e. ready for polling)
type alias PendingConversion =
    {file_id : FileID
    , status_url: URL
    }

-- Details of completed conversion (i.e. ready to download)
type alias CompletedConversion =
    {file_id: FileID
    , download_url: URL
    }

-- Status of a conversion. Either initiated but not complete, complete, or
-- errored.
type
    ConversionStatus
    -- file-id and status URL
    = InProgress PendingConversion
      -- file id and download URL
    | Ok CompletedConversion
    | Err String



-- Full details of a single conversion
type alias Conversion =
    { source_url : URL
    , status : ConversionStatus
    }


type alias Candidate =
    { source_url : URL
    , download_url : URL
    , file_id : FileID
    , timestamp : String
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
    { current_url = ""
    , conversions = []
    , candidates = []
    }
