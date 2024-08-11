class_name Player
extends CharacterBody3D
## This node represents the Player's Character.
## It manages everything about the character's actions.

# --- SIGNALS ---
signal ball_hit(id: int, hit_angle: float, ball: Ball)
## TODO: Describe signal
signal ball_hit_power(id: int, ball: Ball, speed: float, lift_angle: float, rotation_angle: float)
# Signal used to notify when player has served
signal service_hit(player: Player)

# --- ENUMS ---
# Used to describe how the player hit the ball
enum hitType { EARLY_HIT, LATE_HIT, PERFECT_HIT }

# --- CONSTS ---
const MAX_HIT_CHARGE: float = 1.0

# --- EXPORTS ---
# ID used to identify the player from other players
@export var player_id: int = 1
# How fast the player moves in meters per second
@export var default_speed: float = 7
# Current player's speed
@export var speed: float = 7
# Downward acceleration
@export var fall_acceleration: float = 75
# TODO: WHAT is THIS FOR!
@export var active_ability: AbilityComponent

# --- ONREADY ---
@onready var early_hit_zone: Area3D = $OuterHitZone
@onready var late_hit_zone: Area3D = $LateHitZone
@onready var inner_hit_zone: Area3D = $InnerHitZone
@onready var pivot = $Pivot
@onready var character_model = $Pivot/Model

## Current player's velocity
var target_velocity: Vector3 = Vector3.ZERO

## Used to create a new ball on hit
## @deprecated
var ball_scene: Resource = preload("res://scenes/ball.tscn")

## Used to check if the player can hit a ball
var can_hit_ball: bool = false

## Used to check if the ball is inside the early hit zone
var ball_in_early_zone: bool = false

## Used to check if the ball is inside the late hit zone
var ball_in_late_zone: bool = false

## Used to check if the ball is inside the inner/perfect hit zone
var ball_in_inner_zone: bool = false

## Used to know which ball has entered the hit zones
var ball_to_hit: Ball = null

## Used to get the animation player of character
## FIX: Investigate if theres is a better way to handle this
var animation_player: AnimationPlayer = null

## Used to know when a player has started to charge a shot
var shot_started: int

## Player's current state
var _state: PlayerState


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


func _physics_process(delta):
	_state.update(delta, self)


## Changes the [Player] current state to [EndPointState]
func change_to_point_ended_state(_won: bool):
	# TODO: Poner animaciones de victoria o derrota
	_state = PlayerEndPointState.new()


## Changes the [Player] current state to [WaitState]
func change_to_wait_state(wait_position: Vector3):
	_state = PlayerWaitState.new(self, wait_position)


## Changes the [Player] current state to [ReceiveState]
func change_to_receive_state(receive_position: Vector3):
	_state = PlayerReceiveState.new(self, receive_position)


## Changes the [Player] current state to [ServeState]
func change_to_serve_state(serving_position: Vector3):
	_state = PlayerServeState.new(self, serving_position)


## Changes the [Player] current state to [PlayState]
func change_to_play_state(new_ball: Ball):
	_state = PlayerPlayState.new()


## Callback function for ball entering the early hit zone
func _on_early_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_to_hit = body
		ball_in_early_zone = true


## Callback function for ball exiting the early hit zone
func _on_early_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_early_zone = false


## Callback function for ball entering the late hit zone
func _on_late_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_to_hit = body
		ball_in_late_zone = true


## Callback function for ball exiting the late hit zone
func _on_late_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_late_zone = false


## Callback function for ball entering the inner/perfect hit zone
func _on_inner_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_inner_zone = true
		ball_to_hit = body


## Callback function for ball exiting the inner/perfect hit zone
func _on_inner_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_inner_zone = false


## Used when [Player] hits a ball. It creates a new one and destroys the one it hit
## @deprecated
func _deprecated_copy_ball_on_hit(body: Ball, angle_rotation: float):
	var ball_instance: Node = ball_scene.instantiate()
	ball_instance.position = body.global_position + Vector3.FORWARD
	# ball_instance.position = body.position + Vector3.UP * 5
	body.queue_free()
	# var rand_angle = randf() * PI / 4
	# ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, rand_angle - PI / 8)
	ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, angle_rotation)
	get_parent().add_child(ball_instance)


## Caculates the shot power, by the amount of time the player pressed the button
func _get_shot_power(seconds_charged: float):
	print("SECONDS_CHARGED:", seconds_charged)
	var power_chunks = 1.0 / MAX_HIT_CHARGE
	var power_x = power_chunks * min(MAX_HIT_CHARGE, seconds_charged)
	var final_power = 1 - 2 ** (-10 * power_x)
	print("POWER:", final_power)
	return final_power


## Calculates the shot speed bases on the shot charge and lift angle
func _get_shot_speed(seconds_charged: float, lift_angle: float):
	var power = _get_shot_power(seconds_charged)
	## If power is minimal -> the shot should travel at least 9.0 units
	## If power is maximum -> the shot should travel at most 17.0 units
	## FIX: The equations assume the ball is at ground level (which is not)
	var shot_length = 6.0 + 8.0 * power
	return sqrt(shot_length * 10 / sin(2 * lift_angle))
	## Time Based speed (it is not working (dont) know why)
	# Time to travel of the shot!
	# var t = 5.0
	# return shot_length / (cos(lift_angle) * t)


## Manages input a [Player] executes inside a _process function
## Includes hitting ball and activating a skill.
func free_input():
	if Input.is_action_just_pressed("activate_skill_" + str(player_id)) and active_ability:
		active_ability.activate()
	if Input.is_action_just_pressed("hit_ball_" + str(player_id)):
		shot_started = Time.get_ticks_msec()
	elif Input.is_action_just_released("hit_ball_" + str(player_id)):
		var pressed_seconds: float = (Time.get_ticks_msec() - shot_started) / 1000.0
		## Angle the describes the elevation of the hit
		var lift_angle = deg_to_rad(15)
		if ball_in_inner_zone:
			## Angle that describes how far to the left or right it hit the ball
			var hit_angle = 0
			ball_hit_power.emit(
				player_id,
				ball_to_hit,
				_get_shot_speed(pressed_seconds, lift_angle),
				lift_angle,
				hit_angle
			)
			print("PERFECT SHOT!")
		elif ball_in_late_zone:  # Early shot -> to the left
			var hit_angle = randf() * (-PI / 4)
			ball_hit_power.emit(
				player_id,
				ball_to_hit,
				_get_shot_speed(pressed_seconds, lift_angle),
				lift_angle,
				hit_angle
			)
			print("TOO LATE!")
		elif ball_in_early_zone:  # Early shot -> to the right
			var hit_angle = randf() * PI / 4
			ball_hit_power.emit(
				player_id,
				ball_to_hit,
				_get_shot_speed(pressed_seconds, lift_angle),
				lift_angle,
				hit_angle
			)
			print("TOO EARLY!")
		else:
			print("TOO EARLY!")


## Old way that the player's input was managed
## @deprecated
func old_free_input():
	if Input.is_action_just_pressed("activate_skill_" + str(player_id)) and active_ability:
		active_ability.activate()
	if Input.is_action_just_pressed("hit_ball_" + str(player_id)):
		if ball_in_inner_zone:
			var hit_angle = 0
			ball_hit.emit(player_id, hit_angle, ball_to_hit)
			print("PERFECT SHOT!")
		elif ball_in_late_zone:  # Early shot -> to the left
			var hit_angle = randf() * (-PI / 4)
			ball_hit.emit(player_id, hit_angle, ball_to_hit)
			print("TOO LATE!")
		elif ball_in_early_zone:  # Early shot -> to the right
			var hit_angle = randf() * PI / 4
			ball_hit.emit(player_id, hit_angle, ball_to_hit)
			print("TOO EARLY!")
		else:
			print("TOO EARLY!")


## Manages input a [Player] executes inside a _physics_process function
## It includes movement and animations
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

	if direction != Vector3.ZERO:  # Si nos estamos moviendo
		direction = direction.normalized()
		animation_player.play("Walk")

		pivot.basis = Basis.looking_at(direction)
	else:  # No moving
		animation_player.play("Idle")

	# Ground Velocity
	var to_move = Vector3(direction.x * speed, 0, direction.z * speed)

	target_velocity.x = to_move.x
	target_velocity.z = to_move.z
	# Vertical velocity
	if not is_on_floor():  # Falls when not on the ground
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving Character
	velocity = target_velocity
	move_and_slide()
