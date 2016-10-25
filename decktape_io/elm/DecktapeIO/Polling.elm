module DecktapeIO.Polling exposing (..)

import Dict
import DecktapeIO.Json as Json
import DecktapeIO.Msg as Msg
import DecktapeIO.Types as Types
import Http
import Platform.Cmd
import TaskRepeater as TR
import TaskRepeater.Schedulers exposing (uniform)
import Time


type alias Poller =
    TR.Model Http.Error Types.ConversionDetails Time.Time Msg.Msg


type alias Pollers =
    Dict.Dict Types.FileID Poller


update : Pollers -> Types.FileID -> TR.Msg Msg.Msg -> ( Pollers, Platform.Cmd.Cmd Msg.Msg )
update pollers fileID msg =
    case (Dict.get fileID pollers) of
        Just p ->
            let
                ( poller, cmd ) =
                    TR.update msg p

                pollers =
                    Dict.insert fileID poller pollers
            in
                pollers ! [ cmd ]

        Nothing ->
            pollers ! []


statusPoller : Types.URL -> Types.FileID -> Poller
statusPoller statusURL fileID =
    let
        continue convDetails =
            case convDetails of
                Types.Complete _ ->
                    False

                Types.Error _ ->
                    False

                _ ->
                    True

        decoder = Json.statusDecoder fileID statusURL
    in
        TR.model
            (Http.get decoder statusURL)
            (uniform (Time.second * 2))
            (Msg.StatusSuccess fileID)
            (Json.errorToString >> Msg.StatusError fileID)
            (Msg.Poll fileID)
            continue
