extends CharacterBody3D


# How fast the player moves in meters per second
@export var speed : float = 14
# Downward acceleration
@export var fall_acceleration : float = 75

var target_velocity : Vector3 = Vector3.ZERO

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
