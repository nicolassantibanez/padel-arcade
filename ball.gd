extends CharacterBody3D
class_name Ball

var direction = Vector3.ZERO

@export var MAX_SPEED = 300
@export var fall_acc = 10

var air_acc : float = 3

var speed = 15
var target_velocity : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	target_velocity = direction * speed

func _physics_process(delta):
	target_velocity = target_velocity - target_velocity.normalized() * air_acc * delta


	# Gravity
	if not is_on_floor():
		target_velocity.y = target_velocity.y  - (fall_acc * delta)

	
	velocity = target_velocity
	var collision : KinematicCollision3D = move_and_collide(target_velocity * delta)
	if collision:
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		target_velocity = velocity.bounce(collision.get_normal()) * 0.95
		velocity = target_velocity
		move_and_collide(reflect * 0.95)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
