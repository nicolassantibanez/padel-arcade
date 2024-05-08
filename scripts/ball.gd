extends CharacterBody3D
class_name Ball

signal double_bounce(ball: Ball)
signal invalid_serve(ball: Ball)
signal fault(ball: Ball)

@onready var area_detector: Area3D = $Area3D

var direction = Vector3.ZERO

@export var MAX_SPEED = 300
@export var fall_acc = 10

var air_acc: float = 3
var bounces_count = 0
var floor_bounce_count = 0

var speed = 15
var target_velocity: Vector3 = Vector3.ZERO
var is_serve_ball: bool = false
var first_bounce_was_net: bool = false
var crossed_side: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	target_velocity = direction * speed
	area_detector.area_entered.connect(_on_area_detector_area_entered)
	area_detector.area_exited.connect(_on_area_detector_area_exited)

func _physics_process(delta):
	target_velocity = target_velocity - target_velocity.normalized() * air_acc * delta

	# Gravity
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acc * delta)
	
	velocity = target_velocity
	var collision: KinematicCollision3D = move_and_collide(target_velocity * delta)
	if collision:
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		target_velocity = velocity.bounce(collision.get_normal()) * 0.95
		velocity = target_velocity
		move_and_collide(reflect * 0.95)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func disable_detector():
	area_detector.set_deferred("monitoring", false)

func _on_area_detector_area_entered(body: Node3D):
	if is_instance_of(body, CourtSection):
		if body.section_type == CourtSection.SECTION_TYPE.COURT_LINE:
			print("Crossed middle!!")
			crossed_side = true
			return
		bounces_count += 1
		print("Entered area:", body.name)
		if body.section_type == CourtSection.SECTION_TYPE.WALL:
			handle_wall_collision()
		elif body.section_type == CourtSection.SECTION_TYPE.FENCE:
			handle_fence_collision()
		elif body.section_type in [CourtSection.SECTION_TYPE.FRONT_SIDE, CourtSection.SECTION_TYPE.BACK_SIDE]:
			floor_bounce_count += 1
			if floor_bounce_count == 2:
				print("DOUBLE BOUNCE!")
				double_bounce.emit(self)

func _on_area_detector_area_exited(body: Node3D):
	if is_instance_of(body, CourtSection):
		if body.section_type == CourtSection.SECTION_TYPE.COURT_LINE:
			crossed_side = true

func handle_wall_collision():
	if is_serve_ball:
		if crossed_side:
			if bounces_count == 1:
				invalid_serve.emit(self)
		else:
			invalid_serve.emit(self)
	else:
		if crossed_side:
			if bounces_count == 1:
				fault.emit(self)

func handle_fence_collision():
	if is_serve_ball:
		if crossed_side:
			if bounces_count <= 2:
				invalid_serve.emit(self)
		else:
			invalid_serve.emit(self)
	else:
		if crossed_side:
			if bounces_count == 1:
				fault.emit(self)