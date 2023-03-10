module Main exposing (main)

import Html exposing (Html)
import Html.Attributes


main : Html a
main =
    view


view : Html a
view =
    Html.section []
        [ Html.h1 [] [ Html.text "D&D damage dice roller" ]
        ]
