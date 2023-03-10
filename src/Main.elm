module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes


main : Program Flags Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , update = update
        , view = view
        }



-- MODEL


type alias Flags =
    ()


type alias Model =
    {}


initialModel : Model
initialModel =
    {}



-- UPDATE


type Msg
    = Noop


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Html a
view model =
    Html.section []
        [ Html.h1 [] [ Html.text "D&D damage dice roller" ]
        ]
