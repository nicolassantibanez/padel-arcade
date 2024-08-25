class_name DashComponent
extends ActiveAbilityComponent

@export var dash_speed: float = 15

var can_dash: bool = true
var dash_duration: float = 0.2


func _ready():
	super()


func activate():
	if uses <= 0:
		return
	super()
	player_owner.speed = dash_speed
	get_tree().create_timer(dash_duration).timeout.connect(_on_timer_timeout)


func _on_timer_timeout():
	player_owner.speed = player_owner.default_speed
