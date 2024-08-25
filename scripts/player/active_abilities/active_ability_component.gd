class_name ActiveAbilityComponent
extends AbilityComponent

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
@export var cooldown: float = 2

## Cooldown Timer
@onready var cooldown_timer: Timer = Timer.new()


func _ready():
	uses = max_uses
	add_child(cooldown_timer)
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func activate():
	uses -= 1
	if cooldown_timer.is_stopped():
		cooldown_timer.start()


func _on_cooldown_timer_timeout():
	uses += 1
	print("Available: ", uses)

	## If max_uses available, then the timer stops
	if uses == max_uses:
		cooldown_timer.stop()
