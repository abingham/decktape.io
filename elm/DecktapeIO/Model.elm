module DecktapeIO.Model (initialModel, Model) where


type alias Model =
  { url : String
  , submittedUrls : List String
  }


initialModel : Model
initialModel =
  { url = "http://something.example.com"
  , submittedUrls = []
  }
