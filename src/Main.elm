module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Flags =
    ()


type alias Model =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    {}



-- UPDATE


type Msg
    = Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html a
view model =
    Html.section []
        [ Html.h1 [] [ Html.text "D&D damage dice roller" ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub a
subscriptions model =
    Sub.none
