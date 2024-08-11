extends CharacterBody3D
class_name Ball
## Node that represents a Ball

signal cross_side
signal ground_bounce(ball: Ball)
signal wall_bounce(ball: Ball)
signal fence_bounce(ball: Ball)
signal net_bounce(ball: Ball)

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var debug_overlay: DebugOverlay = $DebugOverlay

@export var MAX_SPEED = 300
@export var fall_acc = 10
@export var show_gizmos: bool = false

## How much air deaccelerates the ball
var air_acc: float = 3
## Counts current ball bounces
var bounces_count = 0
## Counts current ball bounces on the ground
var floor_bounce_count = 0

var signals_enabled = true
var target_velocity: Vector3 = Vector3.ZERO
var direction = Vector3.ZERO
var speed = 14
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


func redirect(hit_direction: int, hit_angle: float, power: float):
	self.reset_bounce_count()
	self.is_serve_ball = false
	self.direction = Vector3(0, 0.3, hit_direction).rotated(Vector3.UP, hit_angle).normalized()
	var angle = self.direction.angle_to(Vector3.FORWARD.rotated(Vector3.UP, hit_angle))
	var shot_speed = _get_redirect_speed(power, angle)
	self.target_velocity = self.direction * shot_speed
	print("TARGET VELOCITY: ", self.target_velocity)
	# self.target_velocity = self.direction * self.speed


func _distance_to_wall(shot_direction: Vector3) -> float:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position, 100 * shot_direction)
	var result: Dictionary = space_state.intersect_ray(query)
	if result.get("collider") == null:
		print("NO COLLITION!!!!")
		return 0
	var hit_position: Vector3 = result["position"]
	print("HIT POSITION: ", hit_position)
	debug_overlay.draw.add_vector(self.position, hit_position, 1, 4, Color(0, 1, 0, 0.5))
	# if show_gizmos:
	return position.distance_to(hit_position)


func _get_redirect_speed(power: float, angle: float) -> float:
	# var distance_to_wall = 5
	# X: xf = x0 + v0 * dt
	# x0 + v0*cos(angulo)*t
	# yf = y0
	# vy = v0y + fall_acc * t
	# 0 = v0*sin(angulo) - fall_acc * t
	# 	v0 = (fall_acc * t) / sin(angulo)
	# xf = x0 + v0x * t
	# 	v0 = (xf - x0) / (cos(angulo) * t)
	# t = 2
	#  v0 = (2 * fall_acc) / sin(angulo)

	var shot_length = 9.0 + 8.0 * power
	var distance_to_wall = _distance_to_wall(self.direction - Vector3(0, self.direction.y, 0))
	print("DISTANCE TO WALL: ", distance_to_wall)
	# const base = 4.6415
	const base = 100
	var percentage: float = 0.50 + (base ** power) / 100.0
	# print("PERCENTAGE: ", percentage)
	var dx = percentage * distance_to_wall
	var t = 1
	# var v0 = 150 * dx / (cos(angle) * t)
	# var v0 = dx / (cos(angle) * t)
	var v0 = shot_length / (cos(angle) * t)
	print("SHOT SPEED: ", v0)
	return v0


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
