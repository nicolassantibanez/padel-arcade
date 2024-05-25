class_name Court
extends Node

signal front_side_ball_touch
signal back_side_ball_touch
signal steel_ball_touch()

@onready var ground: StaticBody3D = $Ground
@onready var net: StaticBody3D = $Net
@onready var front_wall: StaticBody3D = $"Walls/Front Wall"
@onready var back_wall: StaticBody3D = $"Walls/Back Wall"
@onready var right_wall: StaticBody3D = $"Walls/Right Wall"
@onready var left_wall: StaticBody3D = $"Walls/Left Wall"
@onready var front_server_marker: Marker3D = $FrontServerPosition
@onready var front_teammate_marker: Marker3D = $FrontTeammatePosition
@onready var back_server_marker: Marker3D = $BackServerPosition
@onready var back_teammate_marker: Marker3D = $BackTeammatePosition
@onready var front_serving_zone: Area3D = $Ground/FrontServingZone
@onready var back_serving_zone: Area3D = $Ground/BackServingZone

var debug_marker_scene: Resource = preload ("res://scenes/debug_marker.tscn")
var front_serving_zone_initial_pos: Vector3
var back_serving_zone_initial_pos: Vector3
#
func get_serving_positions(current_points_sum: int) -> Array[Dictionary]:
	var is_even_point_turn: bool = true if current_points_sum % 2 == 0 else false

	var front_server_pos: Vector3
	var front_teammate_pos: Vector3
	var back_server_pos: Vector3
	var back_teammate_pos: Vector3
	var hit_angle: float
	var front_col_shape: CollisionShape3D = front_serving_zone.get_node("CollisionShape3D")
	var shape_size_x = front_col_shape.shape.get_size().x
	if is_even_point_turn:
		front_serving_zone.position = front_serving_zone_initial_pos
		back_serving_zone.position = back_serving_zone_initial_pos
		front_server_pos = front_server_marker.position
		front_teammate_pos = front_teammate_marker.position
		back_server_pos = back_server_marker.position
		back_teammate_pos = back_teammate_marker.position
		hit_angle = PI / 8
	else: # odd points
		front_serving_zone.position = front_serving_zone_initial_pos - Vector3(shape_size_x, 0, 0)
		back_serving_zone.position = back_serving_zone_initial_pos + Vector3(shape_size_x, 0, 0)
		front_server_pos = front_server_marker.position + 2 * Vector3.LEFT * front_server_marker.position.x
		front_teammate_pos = front_teammate_marker.position + 2 * Vector3.RIGHT * front_teammate_marker.position.x
		back_server_pos = back_server_marker.position - 2 * Vector3.RIGHT * back_server_marker.position.x
		back_teammate_pos = back_teammate_marker.position - 2 * Vector3.LEFT * back_teammate_marker.position.x
		hit_angle = -PI / 8

	var zones: Array[Dictionary] = [
		{
			"server_pos": front_server_pos,
			"teammate_pos": front_teammate_pos,
			"hit_direction": - 1,
			"hit_angle": hit_angle
		},
		{
			"server_pos": back_server_pos,
			"teammate_pos": back_teammate_pos,
			"hit_direction": 1,
			"hit_angle": hit_angle
		}
	]
	# for i in range(2):
	# 	var debug_marker: Node = debug_marker_scene.instantiate()
	# 	if i == 0:
	# 		debug_marker.position = Vector3(zones[0]['x_limits'].x, 1, 0)
	# 	else:
	# 		debug_marker.position = Vector3(zones[0]['x_limits'].y, 1, 0)
	# 	self.add_child(debug_marker)
	# for i in range(2):
	# 	var debug_marker: Node = debug_marker_scene.instantiate()
	# 	if i == 0:
	# 		debug_marker.position = Vector3(0, 1, zones[0]['z_limits'].x)
	# 	else:
	# 		debug_marker.position = Vector3(0, 1, zones[0]['z_limits'].y)
	# 	self.add_child(debug_marker)
	return zones

func ball_hit_serving_zone(ball_pos: Vector3) -> bool:
	var front_col_shape: CollisionShape3D = front_serving_zone.get_node("CollisionShape3D")
	var shape_size_x = front_col_shape.shape.get_size().x
	var shape_size_z = front_col_shape.shape.get_size().z

	var front_x_min = front_serving_zone.position.x - shape_size_x / 2
	var front_x_max = front_serving_zone.position.x + shape_size_x / 2
	var front_z_min = front_serving_zone.position.z - shape_size_z / 2
	var front_z_max = front_serving_zone.position.z + shape_size_z / 2

	var back_x_min = back_serving_zone.position.x - shape_size_x / 2
	var back_x_max = back_serving_zone.position.x + shape_size_x / 2
	var back_z_min = back_serving_zone.position.z - shape_size_z / 2
	var back_z_max = back_serving_zone.position.z + shape_size_z / 2

	var in_front_x = front_x_min <= ball_pos.x and ball_pos.x <= front_x_max
	var in_front_z = front_z_min <= ball_pos.z and ball_pos.z <= front_z_max
	var in_back_x = back_x_min <= ball_pos.x and ball_pos.x <= back_x_max
	var in_back_z = back_z_min <= ball_pos.z and ball_pos.z <= back_z_max
	var is_in_front: bool = in_front_x and in_front_z
	var is_in_back: bool = in_back_x and in_back_z
	print("Is in service box: ", is_in_front or is_in_back)
	return is_in_front or is_in_back

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect parts' signals
	var ground_front_side: Area3D = ground.get_node("./FrontSideArea3D")
	ground_front_side.body_entered.connect(_on_front_side_body_entered)
	var ground_back_side: Area3D = ground.get_node("./BackSideArea3D")
	ground_back_side.body_entered.connect(_on_back_side_body_entered)

	front_serving_zone_initial_pos = front_serving_zone.position
	back_serving_zone_initial_pos = back_serving_zone.position

func _on_front_side_body_entered(node: Node3D):
	if is_instance_of(node, Ball):
		front_side_ball_touch.emit()

func _on_back_side_body_entered(node: Node3D):
	if is_instance_of(node, Ball):
		front_side_ball_touch.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
