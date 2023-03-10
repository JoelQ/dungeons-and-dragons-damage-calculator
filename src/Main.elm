module Main exposing (main)

import Html exposing (Html)
import Html.Attributes


main : Html a
main =
    view initialModel


type alias Model =
    {}


initialModel : Model
initialModel =
    {}


view : Model -> Html a
view model =
    Html.section []
        [ Html.h1 [] [ Html.text "D&D damage dice roller" ]
        ]
