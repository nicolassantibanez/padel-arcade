class_name Player
extends CharacterBody3D

signal ball_hit(id: int, hit_type: hitType, ball: Ball)

enum hitType {EARLY_HIT, LATE_HIT, PERFECT_HIT}

@export var player_id: int = 1
# How fast the player moves in meters per second
@export var speed: float = 7
# Downward acceleration
@export var fall_acceleration: float = 75

@onready var early_hit_zone: Area3D = $OuterHitZone
@onready var late_hit_zone: Area3D = $LateHitZone
@onready var inner_hit_zone: Area3D = $InnerHitZone
@onready var label_hit: RichTextLabel = $LabelHit
@onready var character_model = $Pivot/Model

var target_velocity: Vector3 = Vector3.ZERO
var ball_scene: Resource = preload ("res://ball.tscn")
var debug_marker_scene: Resource = preload ("res://debug_marker.tscn")
# TODO: Example distance (obtener dinamicamente desde la cancha)
var wall_distance = 10

var can_hit_ball: bool = false
var ball_in_early_zone: bool = false
var ball_in_late_zone: bool = false
var ball_in_inner_zone: bool = false
var ball_to_hit: Ball = null
var last_hit_status: String = ""
var animation_player: AnimationPlayer = null

func _ready():
	animation_player = character_model.get_node("./AnimationPlayer")

	early_hit_zone.body_entered.connect(_on_early_hit_zone_body_entered)
	early_hit_zone.body_exited.connect(_on_early_hit_zone_body_exited)

	late_hit_zone.body_entered.connect(_on_late_hit_zone_body_entered)
	late_hit_zone.body_exited.connect(_on_late_hit_zone_body_exited)

	inner_hit_zone.body_entered.connect(_on_inner_hit_zone_body_entered)
	inner_hit_zone.body_exited.connect(_on_inner_hit_zone_body_exited)

func _process(delta):
	if Input.is_physical_key_pressed(KEY_M):
		_add_debug_marker(position)
	
	if Input.is_action_just_pressed("hit_ball_" + str(player_id)):
		if ball_in_inner_zone:
			print("PERFECT SHOT!")
			# _deprecated_copy_ball_on_hit(ball_to_hit, 0)
			ball_hit.emit(player_id, hitType.PERFECT_HIT, ball_to_hit)
			label_hit.clear()
			label_hit.add_text("PERFECT SHOT!")
		elif ball_in_late_zone: # imperfect shot (check if is right or left shot)
			print("TOO LATE!")
			# var rand_angle = randf() * (-PI / 4)
			# _deprecated_copy_ball_on_hit(ball_to_hit, rand_angle)
			ball_hit.emit(player_id, hitType.LATE_HIT, ball_to_hit)
			label_hit.clear()
			label_hit.add_text("TOO LATE!")
		elif ball_in_early_zone:
			print("TOO EARLY!")
			# var rand_angle = randf() * PI / 4
			# _deprecated_copy_ball_on_hit(ball_to_hit, rand_angle)
			ball_hit.emit(player_id, hitType.EARLY_HIT, ball_to_hit)
			label_hit.clear()
			label_hit.add_text("TOO EARLY!")
		else:
			label_hit.clear()
			label_hit.add_text("MISS!")

func _physics_process(delta):
	# local variable to store the input direction
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly
	if Input.is_action_pressed("move_right_" + str(player_id)):
		direction.x += 1
	if Input.is_action_pressed("move_left_" + str(player_id)):
		direction.x -= 1
	if Input.is_action_pressed("move_back_" + str(player_id)):
		direction.z += 1
	if Input.is_action_pressed("move_forward_" + str(player_id)):
		direction.z -= 1
	
	if direction != Vector3.ZERO: # Si nos estamos moviendo
		direction = direction.normalized()
		animation_player.play("Walk")
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)
	else: # No moving
		animation_player.play("Idle")

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical velocity
	if not is_on_floor(): # Falls when not on the ground
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving Character
	velocity = target_velocity
	move_and_slide()

func _on_early_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_to_hit = body
		ball_in_early_zone = true

func _on_early_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_early_zone = false

func _on_late_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_to_hit = body
		ball_in_late_zone = true

func _on_late_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_late_zone = false

func _on_inner_hit_zone_body_entered(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_inner_zone = true
		ball_to_hit = body

func _on_inner_hit_zone_body_exited(body: Node3D):
	if is_instance_of(body, Ball):
		ball_in_inner_zone = false

func _add_debug_marker(pos: Vector3):
	var debug_marker: Node = debug_marker_scene.instantiate()
	debug_marker.position = pos
	get_parent().add_child(debug_marker)

func _deprecated_copy_ball_on_hit(body: Ball, angle_rotation: float):
		var ball_instance: Node = ball_scene.instantiate()
		ball_instance.position = body.global_position + Vector3.FORWARD
		# _add_debug_marker(body.global_position)
		# ball_instance.position = body.position + Vector3.UP * 5
		body.queue_free()
		# var rand_angle = randf() * PI / 4
		# ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, rand_angle - PI / 8)
		ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, angle_rotation)
		get_parent().add_child(ball_instance)
