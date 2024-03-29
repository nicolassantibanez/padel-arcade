extends StaticBody3D

var ball_scene: Resource = preload ("res://ball.tscn")

@onready var throwing_point: Marker3D = $Pivot/ThrowingPoint

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# We check for each move input and update the direction accordingly
	if Input.is_action_just_pressed("shoot_ball"):
		print("Throwing Ball!!!!")
		var ball_instance: Node = ball_scene.instantiate()
		var rand_angle = randf() * PI / 4
		ball_instance.direction = Vector3(0, 0.3, 1).rotated(Vector3.UP, rand_angle - PI / 8)
		ball_instance.position = throwing_point.position
		add_child(ball_instance)