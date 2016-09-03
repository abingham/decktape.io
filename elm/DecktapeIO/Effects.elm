module DecktapeIO.Effects exposing (noFx)

import Platform.Cmd


noFx : model -> ( model, Platform.Cmd.Cmd a )
noFx model =
  ( model, Platform.Cmd.none )
