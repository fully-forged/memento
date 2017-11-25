module View exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Types exposing (..)


root : Model -> Html Msg
root model =
    div [ class "bar" ]
        [ model |> toString |> text ]
