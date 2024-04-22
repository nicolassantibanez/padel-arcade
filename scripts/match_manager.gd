extends Node3D

const ball_scene: Resource = preload ("res://scenes/ball.tscn")
const POINTS = {
	0: 0,
	1: 15,
	2: 30,
	3: 40
}

@export var player1: Player
@export var player2: Player

var team_to_serve

var team1: Dictionary = {
	"points" = 0,
	"games" = 0,
	"sets" = 0,
	"players" = [],
	"hit_direction" = -1
}

var team2: Dictionary = {
	"points" = 0,
	"games" = 0,
	"sets" = 0,
	"players" = [],
	"hit_direction" = 1
}

var serving_team = team1

var balls_in_game = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if randf() <= 0.5:
		team_to_serve = team1
	player1.ball_hit.connect(_on_player_ball_hit)
	player2.ball_hit.connect(_on_player_ball_hit)
	team1.get("players").append(player1)
	team2.get("players").append(player2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var children = get_parent().get_children()
	for child in children:
		if is_instance_of(child, Ball):
			var ball_index = child.get_index()
			if not balls_in_game.has(ball_index):
				balls_in_game[ball_index] = child
				child.double_bounce.connect(_on_ball_double_bounce)

func end_point(_winning_team: Dictionary):
	# End point logic
	# 1. Tell players that the point has ended
	for i in len(team1.get("players")):
		team1.get("players")[i].change_to_point_ended_state(true)
		team2.get("players")[i].change_to_point_ended_state(true)
	# 2. Show point replay
	# TODO: POINT REPLAY
	# 3. Check if game point
	# 3.	true -> change to game point state
	# 			TODO: END CURRENT GAME
	# 3.	false -> change to serve state
	# 			TODO: TELL PLAYERS to switch to serve state
	go_to_serve_state()

func go_to_serve_state():
	for i in len(team1.get("players")):
		team1.get("players")[i].change_to_serve_state(true)
		team2.get("players")[i].change_to_serve_state(true)
	pass

func _on_ball_double_bounce(ball: Ball):
	# Add point to correct team
	# Remove ball
	print("Ball eliminar!")
	if balls_in_game.has(ball.get_index()):
		balls_in_game.erase(ball.get_index())
	ball.queue_free()
	end_point(team1)

func _on_player_ball_hit(player_id: int, hit_angle: float, ball: Ball):
	var hit_direction: int = -1
	print("Player_id:", player_id)
	if player_id == 2:
		hit_direction = 1
	_deprecated_copy_ball_on_hit(ball, hit_direction, hit_angle)

func _deprecated_copy_ball_on_hit(ball: Ball, direction: int, angle_rotation: float):
		var ball_instance: Node = ball_scene.instantiate()
		ball_instance.position = ball.global_position + Vector3.FORWARD
		# _add_debug_marker(body.global_position)
		# ball_instance.position = body.position + Vector3.UP * 5
		ball.queue_free()
		ball = ball_instance
		# var rand_angle = randf() * PI / 4
		# ball_instance.direction = Vector3(0, 0.3, -1).rotated(Vector3.UP, rand_angle - PI / 8)
		ball_instance.direction = Vector3(0, 0.3, direction).rotated(Vector3.UP, angle_rotation)
		get_parent().add_child(ball_instance)
