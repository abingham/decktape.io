module DecktapeIO.TaskRepeater exposing (Model, Msg, Scheduler, start, uniform, update)

import Cmd.Extra exposing (message)
import Platform.Cmd
import Task
import Task.Extra exposing (delay)
import Time


type Msg extmsg
    = Poll
    | Multi (List extmsg)


type alias Scheduler m =
    { model : m
    , next : m -> ( m, Time.Time )
    }


type alias Model extmsg error result s =
    { task : Task.Task error result
    , scheduler : Scheduler s
    , on_success : result -> extmsg
    , on_error : error -> extmsg
    , msg_wrapper : Msg extmsg -> extmsg
    , continue : result -> Bool
    }


uniform : Time.Time -> Scheduler Time.Time
uniform period =
    { model = period
    , next = \last -> ( last, last )
    }


update : Msg extmsg -> Model extmsg error result scheduler -> ( Model extmsg error result scheduler, Platform.Cmd.Cmd extmsg )
update msg model =
    case msg of
        Poll ->
            let
                ( scheduler_model, period ) =
                    model.scheduler.next model.scheduler.model

                s =
                    model.scheduler

                scheduler =
                    { s | model = scheduler_model }

                task =
                    delay period model.task

                msgs result =
                    if (model.continue result) then
                        [ model.on_success result, model.msg_wrapper Poll ]
                    else
                        [ model.on_success result ]

                cmd =
                    Task.perform
                        model.on_error
                        (msgs >> Multi >> model.msg_wrapper)
                        task
            in
                { model | scheduler = scheduler } ! [ cmd ]

        Multi msgs ->
            model ! List.map message msgs


start : Model extmsg error result scheduler -> Platform.Cmd.Cmd extmsg
start model =
    message (model.msg_wrapper Poll)
