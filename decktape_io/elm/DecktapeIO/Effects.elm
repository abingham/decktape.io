module DecktapeIO.Effects exposing (send)

import DecktapeIO.Msg exposing (Msg)
import Platform.Cmd
import Task


send : Msg -> Platform.Cmd.Cmd Msg
send =
    Task.succeed
        >> Task.perform
            identity
            identity
