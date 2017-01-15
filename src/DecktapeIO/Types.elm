module DecktapeIO.Types exposing (..)

-- TODO: Could we instead use `type URL = URL String`? For added type safety...


type alias URL =
    String



-- TODO: Same here...


type alias FileID =
    String


-- TODO: And here...


type alias Timestamp =
    String

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


type alias Suggestion =
    { source_url : URL
    , download_url : URL
    , file_id : FileID
    , timestamp : Timestamp
    }
