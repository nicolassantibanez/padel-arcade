extends CharacterBody3D
class_name Ball

signal cross_side()
signal ground_bounce(ball: Ball)
signal wall_bounce(ball: Ball)
signal fence_bounce(ball: Ball)
signal net_bounce(ball: Ball)

@onready var ray_cast: RayCast3D = $RayCast3D

var direction = Vector3.ZERO

@export var MAX_SPEED = 300
@export var fall_acc = 10

var air_acc: float = 3
var bounces_count = 0
var floor_bounce_count = 0

var signals_enabled = true
# var speed = 15
var speed = 14
var target_velocity: Vector3 = Vector3.ZERO
var is_serve_ball: bool = false
var first_bounce_was_net: bool = false
var current_side: CourtSection.SECTION_TYPE

func reset_bounce_count():
	bounces_count = 0
	floor_bounce_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	target_velocity = direction * speed
	print("Initial Ball velocity: ", target_velocity)

func _process(_delta):
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if is_instance_of(collider, CourtSection) and current_side != collider.section_type:
			print("Side: ", collider.name)
			current_side = collider.section_type
			cross_side.emit()

func _physics_process(delta):
	target_velocity = target_velocity - target_velocity.normalized() * air_acc * delta

	# Gravity
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acc * delta)
	
	velocity = target_velocity
	var collision: KinematicCollision3D = move_and_collide(target_velocity * delta)
	if collision:
		if is_instance_of(collision.get_collider(), CourtSection) and signals_enabled:
			manage_court_sections_collisions(collision.get_collider())
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		target_velocity = velocity.bounce(collision.get_normal()) * 0.95
		velocity = target_velocity
		move_and_collide(reflect * 0.95)

func disable_detector():
	signals_enabled = false
	ray_cast.set_deferred("enabled", false)

func manage_court_sections_collisions(section: CourtSection):
	bounces_count += 1
	if section.section_type == CourtSection.SECTION_TYPE.WALL:
		print("WALL BOUNCE!")
		wall_bounce.emit(self)
	elif section.section_type == CourtSection.SECTION_TYPE.FENCE:
		fence_bounce.emit(self)
	elif section.section_type == CourtSection.SECTION_TYPE.NET:
		bounces_count -= 1
		print("NET BOUNCE!")
		net_bounce.emit(self)
	elif section.section_type == CourtSection.SECTION_TYPE.GROUND:
		print("FlOOR BOUNCE!")
		floor_bounce_count += 1
		ground_bounce.emit(self)