class_name Arrow3D
extends Node3D

@onready var arrow: CSGMesh3D = $Arrow
var curr_angle = 0
var direction = Vector3()

func _ready():
	# var dir = Vector3(1, 1, -1)
	# var d = dir.normalized()
	# var yaw = atan2(d.x, d.z)
	# var pitch = atan2(-d.y, sqrt(d.x * d.x + d.z * d.z))
	# var roll = 0
	# arrow.rotation = Vector3(pitch, yaw, roll)
	pass

func _process(_delta: float) -> void:
	var d = direction.normalized()
	var yaw = atan2(d.x, d.z)
	var pitch = atan2(-d.y, sqrt(d.x * d.x + d.z * d.z))
	var roll = 0
	arrow.rotation = Vector3(pitch, yaw, roll)
