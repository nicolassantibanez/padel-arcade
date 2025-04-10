class_name PlayerServeState
extends PlayerState

signal serve_rotation(rotation: float)

var arrowScene = preload("res://debug/draw_3d.tscn")
var arrow: Arrow3D

# var player: Player
var debug_marker_scene: Resource = preload("res://scenes/debug_marker.tscn")
var shot_rotation: float = 0.0:
	set(value):
		serve_rotation.emit(value)
		shot_rotation = value
var court_side: int = 1
const rotation_speed: float = 5.0


func _init(a_player: Player, service_hit_angle: float, hit_direction: int):
	super(a_player)
	shot_rotation = service_hit_angle
	court_side = hit_direction
	arrow = arrowScene.instantiate()
	a_player.add_child(arrow)


func handle_process(_delta: float):
	# Serve mechanics
	# if press serving button
	# then throw ball to diagonal square
	# Emit signal, that u have serve
	# Manager passes to play state & so do players
	if Input.is_action_just_pressed("hit_ball_" + str(player.player_id)):
		player.start_charging_service()
	elif Input.is_action_just_released("hit_ball_" + str(player.player_id)):
		player.hit_service(shot_rotation)


func handle_physics_process(delta: float):
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly
	# if Input.is_action_pressed("move_right_" + str(player.player_id)):
	# 	direction.x += 1
	# if Input.is_action_pressed("move_left_" + str(player.player_id)):
	# 	direction.x -= 1
	if Input.is_action_pressed("move_right_" + str(player.player_id)):
		# shot_rotation = min(shot_rotation - _delta * rotation_speed, - 50 * PI / 180)
		shot_rotation = shot_rotation + delta * rotation_speed * court_side
	if Input.is_action_pressed("move_left_" + str(player.player_id)):
		# shot_rotation = maxf(shot_rotation + _delta * rotation_speed, 50 * PI / 180)
		shot_rotation = shot_rotation - delta * rotation_speed * court_side

	if direction != Vector3.ZERO:  # Si nos estamos moviendo
		direction = direction.normalized()
		player.animation_player.play("Walk")
		# Setting the basis property will affect the rotation of the node.
		# TODO: Que el jugador mire al frente.
		player.pivot.basis = Basis.looking_at(direction)
	else:  # No moving
		player.animation_player.play("Idle")

	# Ground Velocity
	var to_move = Vector3(direction.x * player.speed, 0, direction.z * player.speed)

	player.target_velocity.x = to_move.x
	player.target_velocity.z = to_move.z
	# Vertical velocity
	if not player.is_on_floor():  # Falls when not on the ground
		player.target_velocity.y = player.target_velocity.y - (player.fall_acceleration * delta)

	# Moving Character
	player.velocity = player.target_velocity
	player.move_and_slide()

	if arrow:
		# arrow.direction = Vector3.BACK.rotated(Vector3.UP, deg_to_rad(shot_rotation))
		arrow.direction = Vector3(0, 0, court_side).rotated(Vector3.UP, shot_rotation)
