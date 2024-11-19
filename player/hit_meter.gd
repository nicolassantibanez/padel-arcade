class_name HitMeter
extends Node3D

## --- EXPORT ---
@export var player: Player

## --- ONREADY ---
@onready var progress_bar: TextureProgressBar = $"Sprite3D/SubViewport/TextureProgressBar"
@onready var reset_timer: Timer = Timer.new()

var started_at: int
var charging: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_timer.autostart = false
	add_child(reset_timer)
	reset_timer.wait_time = player.HIT_COOLDOWN_TIME
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_on_reset_timer_timeout)

	progress_bar.value = 0
	progress_bar.max_value = player.MAX_HIT_CHARGE
	progress_bar.step = player.MAX_HIT_CHARGE / 1000.0
	player.charging_shot_started.connect(_on_player_charging_shot_started)
	player.charging_shot_ended.connect(_on_player_charging_shot_ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if charging:
		progress_bar.value = (Time.get_ticks_msec() - self.started_at) / 1000.0

func _on_player_charging_shot_started(_started_at: int):
	self.started_at = _started_at
	charging = true

func _on_player_charging_shot_ended(_ended_at: int):
	reset_timer.call_deferred("start")
	charging = false


func _on_reset_timer_timeout():
	progress_bar.value = 0
