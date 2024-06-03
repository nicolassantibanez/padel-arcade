extends PlayerState

class_name PlayerServeState

# var player: Player
var debug_marker_scene: Resource = preload ("res://scenes/debug_marker.tscn")

func _init(a_player: Player, serving_position: Vector3):
	print("IN PLAYER SERVE STATE!")
	var player = a_player
	player.global_position = Vector3(serving_position.x, serving_position.y, serving_position.z)

func handle_input(_delta: float, player: Player):
	# Serve mechanics
	# if press serving button
	# then throw ball to diagonal square
	# Emit signal, that u have serve
	# Manager passes to play state & so do players
	if Input.is_action_just_pressed("hit_ball_" + str(player.player_id)):
		player.service_hit.emit(player)

func update(delta: float, player: Player):
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly
	if Input.is_action_pressed("move_right_" + str(player.player_id)):
		direction.x += 1
	if Input.is_action_pressed("move_left_" + str(player.player_id)):
		direction.x -= 1
	# if Input.is_action_pressed("move_back_" + str(player.player_id)):
	#     direction.z += 1
	# if Input.is_action_pressed("move_forward_" + str(player.player_id)):
	#     direction.z -= 1

	if direction != Vector3.ZERO: # Si nos estamos moviendo
		direction = direction.normalized()
		player.animation_player.play("Walk")
		# Setting the basis property will affect the rotation of the node.
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
