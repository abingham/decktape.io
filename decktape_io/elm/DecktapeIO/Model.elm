module DecktapeIO.Model exposing (initialModel, Model, pollers)

{-| The overal application model.
-}

import Dict
import DecktapeIO.Polling as Polling
import DecktapeIO.Types as Types
import Material
import Monocle.Lens exposing (Lens)


type alias Model =
    { current_url : Types.URL
    , conversions : List Types.Conversion
    , suggestions : List Types.Suggestion
    , mdl : Material.Model
    , pollers : Polling.Pollers
    }

pollers : Lens Model Polling.Pollers
pollers =
    Lens .pollers (\p m -> { m | pollers = p })

-- The initial model for the application.


initialModel : Model
initialModel =
    { current_url = ""
    , conversions = []
    , suggestions = []
    , mdl = Material.model
    , pollers = Dict.empty
    }
