extends PlayerState

class_name PlayerServeState

# var player: Player
var debug_marker_scene: Resource = preload ("res://scenes/debug_marker.tscn")
var shot_rotation: float = 0.0

func _init(a_player: Player, serving_position: Vector3):
	print("IN PLAYER SERVE STATE!")
	var player = a_player
	player.global_position = Vector3(serving_position.x, serving_position.y, serving_position.z)

func handle_input(delta: float, player: Player):
	# Serve mechanics
	# if press serving button
	# then throw ball to diagonal square
	# Emit signal, that u have serve
	# Manager passes to play state & so do players
	if Input.is_action_just_pressed("hit_ball_" + str(player.player_id)):
		player.shot_started = Time.get_ticks_msec()
		player.charging_shot_started.emit(player.shot_started)
	elif Input.is_action_just_released("hit_ball_" + str(player.player_id)):
		var ended_at = Time.get_ticks_msec()
		var pressed_seconds: float = (ended_at - player.shot_started) / 1000.0
		player.charging_shot_ended.emit(ended_at)
		## Activate can hit cooldown timer
		player.hit_timer.call_deferred("start")
		# hit_in_cooldown = true
		player.service_power_hit.emit(player, shot_rotation, player._get_shot_speed(pressed_seconds, player.HIT_LIFT_ANGLE))
		# player.service_hit.emit(player)

func update(delta: float, player: Player):
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly
	# if Input.is_action_pressed("move_right_" + str(player.player_id)):
	# 	direction.x += 1
	# if Input.is_action_pressed("move_left_" + str(player.player_id)):
	# 	direction.x -= 1
	if Input.is_action_pressed("move_right_" + str(player.player_id)):
		shot_rotation = min(shot_rotation - delta, - 50 * PI / 180)
	if Input.is_action_pressed("move_left_" + str(player.player_id)):
		shot_rotation = maxf(shot_rotation + delta, 50 * PI / 180)

	if direction != Vector3.ZERO: # Si nos estamos moviendo
		direction = direction.normalized()
		player.animation_player.play("Walk")
		# Setting the basis property will affect the rotation of the node.
		# TODO: Que el jugador mire al frente.
		player.pivot.basis = Basis.looking_at(direction)
	else: # No moving
		player.animation_player.play("Idle")

	# Ground Velocity
	var to_move = Vector3(direction.x * player.speed, 0, direction.z * player.speed)

	player.target_velocity.x = to_move.x
	player.target_velocity.z = to_move.z
	# Vertical velocity
	if not player.is_on_floor(): # Falls when not on the ground
		player.target_velocity.y = player.target_velocity.y - (player.fall_acceleration * delta)

	# Moving Character
	player.velocity = player.target_velocity
	player.move_and_slide()
