extends CharacterBody3D

var direction = Vector3.ZERO

@export var MAX_SPEED = 300
@export var fall_acc = 10

var speed = 2
var target_velocity : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if direction == Vector3.ZERO:
		var rand_angle = randf() * PI
		# direction = Vector3(0, 1, -1).rotated(Vector3.UP, rand_angle - rand_angle / 2)
		direction = Vector3.FORWARD.rotated(Vector3.UP, rand_angle - rand_angle / 2)
		target_velocity = direction * speed
	# var motion = speed * direction * delta

	# Gravity
	if not is_on_floor():
		target_velocity.y = target_velocity.y  - (fall_acc * delta)

	
	velocity = target_velocity
	var collision : KinematicCollision3D = move_and_collide(target_velocity * delta)
	if collision:
		print("Colliding!!!")
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		target_velocity = velocity.bounce(collision.get_normal())
		velocity = target_velocity
		move_and_collide(reflect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
