class_name Court
extends Node

signal front_side_ball_touch
signal back_side_ball_touch
signal steel_ball_touch()

@onready var ground: StaticBody3D = $Ground
@onready var net: StaticBody3D = $Net
@onready var front_wall: StaticBody3D = $"Front Wall"
@onready var back_wall: StaticBody3D = $"Back Wall"
@onready var right_wall: StaticBody3D = $"Right Wall"
@onready var left_wall: StaticBody3D = $"Left Wall"
@onready var front_server_marker: Marker3D = $FrontServerPosition
@onready var front_teammate_marker: Marker3D = $FrontTeammatePosition
@onready var back_server_marker: Marker3D = $BackServerPosition
@onready var back_teammate_marker: Marker3D = $BackTeammatePosition

var debug_marker_scene: Resource = preload ("res://scenes/debug_marker.tscn")
#
func get_serving_positions(current_points_sum: int) -> Array[Dictionary]:
	var is_even_point_turn: bool = true if current_points_sum % 2 == 0 else false

	var front_server_pos: Vector3
	var front_teammate_pos: Vector3
	var back_server_pos: Vector3
	var back_teammate_pos: Vector3
	print("Nodo listo?:", is_node_ready())
	if is_even_point_turn:
		front_server_pos = front_server_marker.position
		front_teammate_pos = front_teammate_marker.position
		back_server_pos = back_server_marker.position
		back_teammate_pos = back_teammate_marker.position
	else: # odd points
		front_server_pos = front_server_marker.position + 2 * Vector3.LEFT * front_server_marker.position.x
		front_teammate_pos = front_teammate_marker.position + 2 * Vector3.RIGHT * front_teammate_marker.position.x
		back_server_pos = back_server_marker.position - 2 * Vector3.RIGHT * back_server_marker.position.x
		back_teammate_pos = back_teammate_marker.position - 2 * Vector3.LEFT * back_teammate_marker.position.x

	var zones: Array[Dictionary] = [
		{
			"server_pos": front_server_pos,
			"teammate_pos": front_teammate_pos,
			"hit_direction": - 1
		},
		{
			"server_pos": back_server_pos,
			"teammate_pos": back_teammate_pos,
			"hit_direction": 1
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

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect parts' signals
	var ground_front_side: Area3D = ground.get_node("./FrontSideArea3D")
	ground_front_side.body_entered.connect(_on_front_side_body_entered)
	var ground_back_side: Area3D = ground.get_node("./BackSideArea3D")
	ground_back_side.body_entered.connect(_on_back_side_body_entered)

func _on_front_side_body_entered(node: Node3D):
	if is_instance_of(node, Ball):
		front_side_ball_touch.emit()

func _on_back_side_body_entered(node: Node3D):
	if is_instance_of(node, Ball):
		front_side_ball_touch.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
