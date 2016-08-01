module DecktapeIO.Model (initialModel, Model, URL) where

-- TODO: replace these with aliases from existing libraries?


type alias URL =
  String


type alias Result =
  { source_url : URL
  , result_url : URL
  }


type alias Model =
  { url : String
  , submittedUrls : List Result
  }


initialModel : Model
initialModel =
  { url = "http://something.example.com"
  , submittedUrls = []
  }
