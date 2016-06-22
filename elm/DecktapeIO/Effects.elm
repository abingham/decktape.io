module DecktapeIO.Effects (noFx) where

import Effects


noFx : model -> ( model, Effects.Effects a )
noFx model =
  ( model, Effects.none )
