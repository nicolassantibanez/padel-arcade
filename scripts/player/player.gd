class_name Player
extends CharacterBody3D

signal ball_hit(id: int, hit_angle: float, ball: Ball)
signal service_hit(player: Player)

enum hitType {EARLY_HIT, LATE_HIT, PERFECT_HIT}

@export var player_id: int = 1
# How fast the player moves in meters per second
@export var speed: float = 7
# Downward acceleration
@export var fall_acceleration: float = 75

@onready var early_hit_zone: Area3D = $OuterHitZone
@onready var late_hit_zone: Area3D = $LateHitZone
@onready var inner_hit_zone: Area3D = $InnerHitZone
@onready var pivot = $Pivot
@onready var character_model = $Pivot/Model

var target_velocity: Vector3 = Vector3.ZERO
var ball_scene: Resource = preload ("res://scenes/ball.tscn")
var debug_marker_scene: Resource = preload ("res://scenes/debug_marker.tscn")

var can_hit_ball: bool = false
var ball_in_early_zone: bool = false
var ball_in_late_zone: bool = false
var ball_in_inner_zone: bool = false
var ball_to_hit: Ball = null
var last_hit_status: String = ""
var animation_player: AnimationPlayer = null
var playing_ball: Ball

var _state: PlayerState

#
func change_to_point_ended_state(_won: bool):
	# TODO: Poner animaciones de victoria o derrota
	# Bloquear movimientos
	_state = PlayerEndPointState.new()

func change_to_wait_state(wait_position: Vector3):
	_state = PlayerWaitState.new(self, wait_position)

func change_to_receive_state(receive_position: Vector3):
	_state = PlayerReceiveState.new(self, receive_position)

func change_to_serve_state(serving_position: Vector3):
	_state = PlayerServeState.new(self, serving_position)

func change_to_play_state(new_ball: Ball):
	_state = PlayerPlayState.new(self, new_ball)

func _ready():
	_state = PlayerPlayState.new(self, null)
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

func free_input():
	if Input.is_action_just_pressed("hit_ball_" + str(player_id)):
		if ball_in_inner_zone:
			var hit_angle = 0
			ball_hit.emit(player_id, hit_angle, ball_to_hit)
			print("PERFECT SHOT!")
		elif ball_in_late_zone: # Early shot -> to the left
			var hit_angle = randf() * (-PI / 4)
			ball_hit.emit(player_id, hit_angle, ball_to_hit)
			print("TOO LATE!")
		elif ball_in_early_zone: # Early shot -> to the right
			var hit_angle = randf() * PI / 4
			ball_hit.emit(player_id, hit_angle, ball_to_hit)
			print("TOO EARLY!")
		else:
			print("TOO EARLY!")

# Manages Player's free movement
# ALRERT: Only use inside physics process
func normal_movement(delta):
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly
	if Input.is_action_pressed("move_right_" + str(player_id)):
		direction.x += 1
	if Input.is_action_pressed("move_left_" + str(player_id)):
		direction.x -= 1
	if Input.is_action_pressed("move_back_" + str(player_id)):
		direction.z += 1
	if Input.is_action_pressed("move_forward_" + str(player_id)):
		direction.z -= 1

	if direction != Vector3.ZERO: # Si nos estamos moviendo
		direction = direction.normalized()
		animation_player.play("Walk")
		# Setting the basis property will affect the rotation of the node.
		pivot.basis = Basis.looking_at(direction)
	else: # No moving
		animation_player.play("Idle")

	# Ground Velocity
	var to_move = Vector3(direction.x * speed, 0, direction.z * speed)

	target_velocity.x = to_move.x
	target_velocity.z = to_move.z
	# Vertical velocity
	if not is_on_floor(): # Falls when not on the ground
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving Character
	velocity = target_velocity
	move_and_slide()
