module DecktapeIO.Effects exposing (noFx, send)

import DecktapeIO.Msg exposing (Msg)
import Platform.Cmd
import Task


noFx : model -> ( model, Platform.Cmd.Cmd a )
noFx model =
    ( model, Platform.Cmd.none )


send : Msg -> Platform.Cmd.Cmd Msg
send msg =
    Task.succeed 0
        |> Task.perform
            (\_ -> msg)
            (\_ -> msg)
