module Main exposing (..)

import Html
import Platform.Sub as Sub
import Types exposing (..)
import State
import View


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = State.init
        , view = View.root
        , update = State.update
        , subscriptions = subscriptions
        }
