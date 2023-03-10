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
    { roll : Int
    , modifier : AttackModifier
    }


type AttackModifier
    = Normal
    | Advantage
    | Disadvantage


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { roll = 0
    , modifier = Normal
    }



-- UPDATE


type Msg
    = RollDamage
    | AttackRolled Int
    | ModifierChosen AttackModifier


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDamage ->
            ( model, Random.generate AttackRolled (attack model.modifier) )

        AttackRolled newAttack ->
            ( { model | roll = newAttack }, Cmd.none )

        ModifierChosen newModifier ->
            ( { model | modifier = newModifier }, Cmd.none )


attack : AttackModifier -> Generator Int
attack modifier =
    case modifier of
        Normal ->
            normal

        Advantage ->
            advantage

        Disadvantage ->
            disadvantage


normal : Generator Int
normal =
    d20


advantage : Generator Int
advantage =
    Random.map2 max d20 d20


disadvantage : Generator Int
disadvantage =
    Random.map2 min d20 d20


d20 : Generator Int
d20 =
    Random.int 1 20



-- VIEW


view : Model -> Html Msg
view model =
    Html.section []
        [ Html.h1 [] [ Html.text "D&D damage dice roller" ]
        , Html.form [ Html.Events.onSubmit RollDamage ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text "Modifiers" ]
                , Html.label [ Html.Attributes.for "normal" ] [ Html.text "Normal" ]
                , Html.input
                    [ Html.Attributes.id "normal"
                    , Html.Attributes.type_ "radio"
                    , Html.Attributes.checked <| model.modifier == Normal
                    , Html.Events.onCheck (\_ -> ModifierChosen Normal)
                    ]
                    []
                , Html.label [ Html.Attributes.for "advantage" ] [ Html.text "Advantage" ]
                , Html.input
                    [ Html.Attributes.id "advantage"
                    , Html.Attributes.type_ "radio"
                    , Html.Attributes.checked <| model.modifier == Advantage
                    , Html.Events.onCheck (\_ -> ModifierChosen Advantage)
                    ]
                    []
                , Html.label [ Html.Attributes.for "disadvantage" ] [ Html.text "Disadvantage" ]
                , Html.input
                    [ Html.Attributes.id "disadvantage"
                    , Html.Attributes.type_ "radio"
                    , Html.Attributes.checked <| model.modifier == Disadvantage
                    , Html.Events.onCheck (\_ -> ModifierChosen Disadvantage)
                    ]
                    []
                ]
            , Html.button [] [ Html.text "Roll Attack" ]
            ]
        , Html.div [] [ Html.text <| "Rolled: " ++ String.fromInt model.roll ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub a
subscriptions model =
    Sub.none
