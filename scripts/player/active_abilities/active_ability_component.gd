class_name ActiveAbilityComponent
extends AbilityComponent

@export var player_owner: Player

## The max number of uses of a skill, before cooldown
@export var max_uses: int = 1:
    get:
        return max_uses
    set(value):
        max_uses = max(value, 0)

## The current number of uses left of a skill before cooldown
@export var uses: int = 1:
    get:
        return uses
    set(value):
        uses = min(max(value, 0), max_uses)

## Cooldown for the ability
@export var cooldown: float = 3

func _ready():
    uses = max_uses