extends CharacterBody3D

# How fast the player moves in meters per second
@export var speed: float = 14
# Downward acceleration
@export var fall_acceleration: float = 75

@onready var hit_zone: Area3D = $HitZone

var target_velocity: Vector3 = Vector3.ZERO
var ball_scene: Resource = preload ("res://ball.tscn")
var debug_marker_scene: Resource = preload ("res://debug_marker.tscn")
# TODO: Example distance (obtener dinamicamente desde la cancha)
var wall_distance = 10

func _ready():
	hit_zone.body_entered.connect(_on_hit_zone_body_entered)

func _process(delta):
	if Input.is_physical_key_pressed(KEY_M):
		_add_debug_marker(position)

func _physics_process(delta):
	# local variable to store the input direction
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	if direction != Vector3.ZERO: # Si nos estamos moviendo
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical velocity
	if not is_on_floor(): # Falls when not on the ground
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving Character
	velocity = target_velocity
	move_and_slide()

func _on_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		_deprecated_copy_ball_on_hit(body)
		var ball_instance: Node = ball_scene.instantiate()
		ball_instance.position = body.global_position + Vector3.FORWARD
		# _add_debug_marker(body.global_position)
		# ball_instance.position = body.position + Vector3.UP * 5
		body.queue_free()
		var rand_angle = randf() * PI / 4
		ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, rand_angle - PI / 8)
		get_parent().add_child(ball_instance)

func _add_debug_marker(pos: Vector3):
	var debug_marker: Node = debug_marker_scene.instantiate()
	debug_marker.position = pos
	get_parent().add_child(debug_marker)

func _deprecated_copy_ball_on_hit(body: Ball):
		var ball_instance: Node = ball_scene.instantiate()
		ball_instance.position = body.global_position + Vector3.FORWARD
		# _add_debug_marker(body.global_position)
		# ball_instance.position = body.position + Vector3.UP * 5
		body.queue_free()
		var rand_angle = randf() * PI / 4
		ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, rand_angle - PI / 8)
		get_parent().add_child(ball_instance)