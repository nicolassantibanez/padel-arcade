class_name Player
extends CharacterBody3D

signal ball_hit(id: int, hit_angle: float, ball: Ball)

enum hitType {EARLY_HIT, LATE_HIT, PERFECT_HIT}

@export var player_id: int = 1
# How fast the player moves in meters per second
@export var speed: float = 7
# Downward acceleration
@export var fall_acceleration: float = 75

@onready var early_hit_zone: Area3D = $OuterHitZone
@onready var late_hit_zone: Area3D = $LateHitZone
@onready var inner_hit_zone: Area3D = $InnerHitZone
@onready var label_hit: RichTextLabel = $LabelHit
@onready var pivot = $Pivot
@onready var character_model = $Pivot/Model

var target_velocity: Vector3 = Vector3.ZERO
var ball_scene: Resource = preload ("res://scenes/ball.tscn")
var debug_marker_scene: Resource = preload ("res://scenes/debug_marker.tscn")
# TODO: Example distance (obtener dinamicamente desde la cancha)
var wall_distance = 10

var can_hit_ball: bool = false
var ball_in_early_zone: bool = false
var ball_in_late_zone: bool = false
var ball_in_inner_zone: bool = false
var ball_to_hit: Ball = null
var last_hit_status: String = ""
var animation_player: AnimationPlayer = null

var _state: PlayerState

#
func change_to_point_ended_state(won: bool):
	# TODO: Poner animaciones de victoria o derrota
	# Bloquear movimientos
	_state = PlayerEndPointState.new()

func change_to_serve_state(won: bool):
	# TODO: Poner animaciones de victoria o derrota
	# Bloquear movimientos
	# Limitar movimientos solo a la mitad de cancha correspondientes
	_state = PlayerServeState.new()

func _ready():
	_state = PlayerPlayState.new()
	animation_player = character_model.get_node("./AnimationPlayer")

	early_hit_zone.body_entered.connect(_on_early_hit_zone_body_entered)
	early_hit_zone.body_exited.connect(_on_early_hit_zone_body_exited)

	late_hit_zone.body_entered.connect(_on_late_hit_zone_body_entered)
	late_hit_zone.body_exited.connect(_on_late_hit_zone_body_exited)

	inner_hit_zone.body_entered.connect(_on_inner_hit_zone_body_entered)
	inner_hit_zone.body_exited.connect(_on_inner_hit_zone_body_exited)

func _process(delta):
	_state.handle_input(delta, self)
	if Input.is_physical_key_pressed(KEY_M):
		_add_debug_marker(position)

func _physics_process(delta):
	_state.update(delta, self)

func _on_early_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_to_hit = body
		ball_in_early_zone = true

func _on_early_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_early_zone = false

func _on_late_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_to_hit = body
		ball_in_late_zone = true

func _on_late_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_late_zone = false

func _on_inner_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_inner_zone = true
		ball_to_hit = body

func _on_inner_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_inner_zone = false

func _add_debug_marker(pos: Vector3):
	var debug_marker: Node = debug_marker_scene.instantiate()
	debug_marker.position = pos
	get_parent().add_child(debug_marker)

func _deprecated_copy_ball_on_hit(body: Ball, angle_rotation: float):
		var ball_instance: Node = ball_scene.instantiate()
		ball_instance.position = body.global_position + Vector3.FORWARD
		# _add_debug_marker(body.global_position)
		# ball_instance.position = body.position + Vector3.UP * 5
		body.queue_free()
		# var rand_angle = randf() * PI / 4
		# ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, rand_angle - PI / 8)
		ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, angle_rotation)
		get_parent().add_child(ball_instance)