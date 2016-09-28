module DecktapeIO exposing (..)

-- import DecktapeIO.Effects exposing (noFx)
import DecktapeIO.Model exposing (initialModel)
import DecktapeIO.Msg
import DecktapeIO.Update exposing (update)
import DecktapeIO.View exposing (view)
import Html.App as Html
import Material.Layout

main : Program Never
main =
   Html.program
    { init = ( initialModel, Material.Layout.sub0 DecktapeIO.Msg.Mdl )
    , view = view
    , update = update
    , subscriptions = always Sub.none -- Material.Layout.subs DecktapeIO.Msg.Mdl initialModel
    }
