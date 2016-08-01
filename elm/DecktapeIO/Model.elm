module DecktapeIO.Model (ID, initialModel, Model, URL) where

-- TODO: replace these with aliases from existing libraries?
type alias URL = String
type alias ID = String

type alias Model =
  { url : String
  , submittedUrls : List (URL, ID)
  }


initialModel : Model
initialModel =
  { url = "http://something.example.com"
  , submittedUrls = []
  }
