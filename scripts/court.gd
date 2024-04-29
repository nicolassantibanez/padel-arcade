class_name Court
extends Node

signal front_side_ball_touch
signal back_side_ball_touch

@onready var ground: StaticBody3D = $Ground
@onready var net: StaticBody3D = $Net
@onready var front_wall: StaticBody3D = $"Front Wall"
@onready var back_wall: StaticBody3D = $"Back Wall"
@onready var right_wall: StaticBody3D = $"Right Wall"
@onready var left_wall: StaticBody3D = $"Left Wall"

#
func get_serving_zones() -> Array[Dictionary]:
	# FIX: For the moment I'll assume serving boxes are at the middle
	var front_side: Area3D = ground.get_node("./FronSideArea3D")
	var front_collision_shape: CollisionShape3D = front_side.get_node("./CollisionShape3D")
	var back_side: Area3D = ground.get_node("./FronSideArea3D")
	var back_collision_shape: CollisionShape3D = back_side.get_node("./CollisionShape3D")
	# FIX: Aquí me equivoqué. Recordar que estamos calculando dónde el jugador tiene que estar al servir
	# Por esto mismo, hay que cambiar el z_limits de ambos lados
	return [
		{
			"x_limits": Vector2(front_side.position.x - front_collision_shape.get_size().x, front_side.position.x + front_collision_shape.get_size().x),
			"z_limits": Vector2(front_side.position.z - front_collision_shape.get_size().z, front_side.position.z + front_collision_shape.get_size().z),
		},
		{
			"x_limits": Vector2(back_side.position.x - back_collision_shape.get_size().x, back_side.position.x + back_collision_shape.get_size().x),
			"z_limits": Vector2(back_side.position.z - back_collision_shape.get_size().z, back_side.position.z + back_collision_shape.get_size().z),
		},
	]

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
