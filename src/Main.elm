module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Random exposing (Generator)


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
    { roll : Int }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { roll = 0 }



-- UPDATE


type Msg
    = RollDamage
    | AttackRolled Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDamage ->
            ( model, Random.generate AttackRolled d20 )

        AttackRolled newAttack ->
            ( { model | roll = newAttack }, Cmd.none )


d20 : Generator Int
d20 =
    Random.int 1 20



-- VIEW


view : Model -> Html Msg
view model =
    Html.section []
        [ Html.h1 [] [ Html.text "D&D damage dice roller" ]
        , Html.button [ Html.Events.onClick RollDamage ] [ Html.text "Roll Attack" ]
        , Html.div [] [ Html.text <| "Rolled: " ++ String.fromInt model.roll ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub a
subscriptions model =
    Sub.none
