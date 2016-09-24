module DecktapeIO.Model exposing (..)


type alias URL =
    String


type alias FileID =
    String


type alias Timestamp =
    String



-- The result of a successful call to /status
-- TODO: Experiment with extensible records here. And see how they improve (if at all) the update functions.)


type alias StatusLocator =
    { file_id : FileID
    , status_url : URL
    }


type alias InProgressDetails =
    { timestamp : Timestamp, status_msg : String, locator : StatusLocator }


type alias CompleteDetails =
    { locator : StatusLocator, timestamp : Timestamp, download_url : URL }



-- Full details of a single conversion


type ConversionDetails
    = Initiated StatusLocator
    | InProgress InProgressDetails
    | Complete CompleteDetails
    | Error String


type alias Conversion =
    { source_url : URL
    , details : ConversionDetails
    }


type alias Candidate =
    { source_url : URL
    , download_url : URL
    , file_id : FileID
    , timestamp : Timestamp
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
