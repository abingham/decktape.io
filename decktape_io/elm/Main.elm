module DecktapeIO exposing (..)

import DecktapeIO.Model exposing (initialModel)
import DecktapeIO.Msg
import DecktapeIO.Update exposing (update)
import DecktapeIO.View exposing (view)
import Html.App as Html
import Material


main : Program Never
main =
    Html.program
        { init = ( initialModel, Material.init DecktapeIO.Msg.Mdl )
        , view = view
        , update = update
        , subscriptions = Material.subscriptions DecktapeIO.Msg.Mdl
        }
