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
    , damage : Int
    , modifier : AttackModifier
    , enemyAC : Int
    }


type alias CompositeRoll =
    { attacks : List Int
    , aggregate : Int
    }


type AttackStatus
    = Miss
    | Hit
    | Crit


isHit : { roll : Int, ac : Int } -> AttackStatus
isHit { roll, ac } =
    if roll == 20 then
        Crit

    else if roll >= ac then
        Hit

    else
        Miss


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
    , damage = 0
    , enemyAC = 10
    }



-- UPDATE


type Msg
    = RollDamage
    | AttackRolled CompositeRoll
    | DamageRolled Int
    | ModifierChosen AttackModifier


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDamage ->
            ( model, Random.generate AttackRolled (attackGen model.modifier) )

        AttackRolled newAttack ->
            ( { model | roll = newAttack }
            , Random.generate DamageRolled
                (damageGen <|
                    isHit
                        { roll =
                            newAttack.aggregate
                        , ac = model.enemyAC
                        }
                )
            )

        DamageRolled newDamage ->
            ( { model | damage = newDamage }, Cmd.none )

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


damageGen : AttackStatus -> Generator Int
damageGen status =
    case status of
        Crit ->
            criticalDamage

        Hit ->
            regularDamage

        Miss ->
            noDamage


criticalDamage : Generator Int
criticalDamage =
    Random.map2 (+) d6 d6


regularDamage : Generator Int
regularDamage =
    d6


noDamage : Generator Int
noDamage =
    Random.constant 0


d6 : Generator Int
d6 =
    d 6


d20 : Generator Int
d20 =
    d 20


d : Int -> Generator Int
d n =
    Random.int 1 n



-- VIEW


view : Model -> Html Msg
view model =
    Html.section []
        [ Html.h1 [] [ Html.text "D&D damage dice roller" ]
        , Html.p [] [ Html.text <| "AC to beat: " ++ String.fromInt model.enemyAC ]
        , Html.form [ Html.Events.onSubmit RollDamage ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text "Modifiers" ]
                , Html.label [ Html.Attributes.for "normal" ] [ Html.text "Normal" ]
                , radioInput "normal" (model.modifier == Normal) (ModifierChosen Normal)
                , Html.label [ Html.Attributes.for "advantage" ] [ Html.text "Advantage" ]
                , radioInput "advantage" (model.modifier == Advantage) (ModifierChosen Advantage)
                , Html.label [ Html.Attributes.for "disadvantage" ] [ Html.text "Disadvantage" ]
                , radioInput "disadvantage" (model.modifier == Disadvantage) (ModifierChosen Disadvantage)
                ]
            , Html.button [] [ Html.text "Roll Attack" ]
            ]
        , viewCompositeRoll model.roll model.enemyAC model.damage
        ]


radioInput : String -> Bool -> Msg -> Html Msg
radioInput id isChecked msg =
    Html.input
        [ Html.Attributes.id id
        , Html.Attributes.type_ "radio"
        , Html.Attributes.checked isChecked
        , Html.Events.onCheck (\_ -> msg)
        ]
        []


viewCompositeRoll : CompositeRoll -> Int -> Int -> Html a
viewCompositeRoll roll enemyAC damage =
    Html.section []
        [ Html.p []
            [ Html.text <|
                "Rolled: "
                    ++ String.fromInt roll.aggregate
                    ++ " ("
                    ++ viewAttackStatus (isHit { roll = roll.aggregate, ac = enemyAC })
                    ++ ")"
            ]
        , Html.ul [] (List.map viewAttackRoll roll.attacks)
        , Html.p [] [ Html.text <| "Damage: " ++ String.fromInt damage ]
        ]


viewAttackStatus : AttackStatus -> String
viewAttackStatus status =
    case status of
        Crit ->
            "critical!"

        Hit ->
            "hit!"

        Miss ->
            "miss!"


viewAttackRoll : Int -> Html a
viewAttackRoll attack =
    Html.li [] [ Html.text (String.fromInt attack) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub a
subscriptions model =
    Sub.none
