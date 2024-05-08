@tool
class_name InvisibleCage
extends StaticBody3D

@export var zone_width: float = 4
@export var zone_length: float = 4
@export var wall_width: float = 0.5
@export var wall_height: float = 2

@onready var back_wall: CollisionShape3D = $BackWall
@onready var right_wall: CollisionShape3D = $RightWall
@onready var left_wall: CollisionShape3D = $LeftWall
@onready var front_wall: CollisionShape3D = $FrontWall

var all_walls: Array[CollisionShape3D] = [
	back_wall,
	right_wall,
	left_wall,
	front_wall
]

var started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.is_editor_hint():
		setup()

func setup():
	# Define wall width & length
	back_wall.get_shape().set_size(Vector3(zone_width, wall_height, wall_width))
	right_wall.get_shape().set_size(Vector3(wall_width, wall_height, zone_length))
	left_wall.get_shape().set_size(Vector3(wall_width, wall_height, zone_length))
	front_wall.get_shape().set_size(Vector3(zone_width, wall_height, wall_width))

	# Define wall positions
	back_wall.position = Vector3(0, 0, -zone_length - wall_width) / 2
	right_wall.position = Vector3( - zone_width - wall_width, 0, 0) / 2
	left_wall.position = Vector3(zone_width + wall_width, 0, 0) / 2
	front_wall.position = Vector3(0, 0, zone_length + wall_width) / 2