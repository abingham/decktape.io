module DecktapeIO.Model exposing (conversions, current_url, initialModel, Model, pollers, suggestions)

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

current_url : Lens Model Types.URL
current_url =
    Lens .current_url (\u m -> {m | current_url = u})

conversions : Lens Model (List Types.Conversion)
conversions =
    Lens .conversions (\c m -> {m | conversions = c})

suggestions : Lens Model (List Types.Suggestion)
suggestions  =
    Lens .suggestions (\s m -> {m | suggestions = s})

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
