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
    { roll : CompositeRoll
    , modifier : AttackModifier
    }


type alias CompositeRoll =
    { attacks : List Int
    , aggregate : Int
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
    { roll = { attacks = [], aggregate = 0 }
    , modifier = Normal
    }



-- UPDATE


type Msg
    = RollDamage
    | AttackRolled CompositeRoll
    | ModifierChosen AttackModifier


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDamage ->
            ( model, Random.generate AttackRolled (attackGen model.modifier) )

        AttackRolled newAttack ->
            ( { model | roll = newAttack }, Cmd.none )

        ModifierChosen newModifier ->
            ( { model | modifier = newModifier }, Cmd.none )


attackGen : AttackModifier -> Generator CompositeRoll
attackGen modifier =
    case modifier of
        Normal ->
            normal

        Advantage ->
            advantage

        Disadvantage ->
            disadvantage


normal : Generator CompositeRoll
normal =
    Random.map (\roll -> { attacks = [ roll ], aggregate = roll })
        d20


advantage : Generator CompositeRoll
advantage =
    Random.map2
        (\roll1 roll2 -> { attacks = [ roll1, roll2 ], aggregate = max roll1 roll2 })
        d20
        d20


disadvantage : Generator CompositeRoll
disadvantage =
    Random.map2
        (\roll1 roll2 -> { attacks = [ roll1, roll2 ], aggregate = min roll1 roll2 })
        d20
        d20


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
        , viewCompositeRoll model.roll
        ]


viewCompositeRoll : CompositeRoll -> Html a
viewCompositeRoll roll =
    Html.section []
        [ Html.p [] [ Html.text <| "Rolled: " ++ String.fromInt roll.aggregate ]
        , Html.ul [] (List.map viewAttackRoll roll.attacks)
        ]


viewAttackRoll : Int -> Html a
viewAttackRoll attack =
    Html.li [] [ Html.text (String.fromInt attack) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub a
subscriptions model =
    Sub.none
