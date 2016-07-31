module DecktapeIO.Model (initialModel, Model, Path, URL) where

-- TODO: replace these with aliases from existing libraries?
type alias URL = String
type alias Path = String

type alias Model =
  { url : String
  , submittedUrls : List (URL, Path)
  }


initialModel : Model
initialModel =
  { url = "http://something.example.com"
  , submittedUrls = []
  }
