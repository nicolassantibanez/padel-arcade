class_name LightningShotComponent
extends ActiveAbilityComponent

@export var shot_speed_multiplier: float = 2

var is_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	player_owner.ball_hit_power.connect(_on_player_ball_hit_power)

func activate():
	if is_active: # Can be deactivated when trying to activate again the abilitie
		is_active = false
	if uses <= 0 or is_active:
		return
	super()
	player_owner.shot_speed_multiplier = shot_speed_multiplier

## Callback function to deactivate ability when user hits the ball
func _on_player_ball_hit_power(_id: int, _ball: Ball, _speed: float, _speed_multiplier: float, _lift_angle: float, _rotation_angle: float):
	if is_active:
		player_owner.shot_speed_multiplier = 1
		is_active = false
