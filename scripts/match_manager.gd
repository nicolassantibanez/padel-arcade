@tool
class_name MatchManager
extends Node3D

signal update_points_ui(teams: Array[TeamManager])
signal point_ended(winning_team: TeamManager)
signal game_ended()
signal set_ended()
signal match_ended()
signal serve_ended()

const ball_scene: Resource = preload ("res://scenes/ball.tscn")
const POINTS = {
	0: 0,
	1: 15,
	2: 30,
	3: 40,
	4: 'ADV'
}

@export var player1: Player
@export var player2: Player

var teams: Array[TeamManager] = []
var serving_team: TeamManager
var current_turn_index: int
var ui_manager: UIManager
var court: Court

var balls_in_game = {}
var _state: MatchManagerState

# Use setters to update the configuration warning automatically.
func _get_configuration_warnings():
	var warnings = []

	for co_node in get_parent().get_children():
		if is_instance_of(co_node, UIManager):
			ui_manager = co_node
	
	if not ui_manager:
		warnings.append("UIManager is missing in the scene tree!")

	# Returning an empty array means "no warning".
	return warnings

# Called when the node enters the scene tree for the first time.
func _ready():
	_state = MatchManagerStartState.new()
	_load_dependencies()
	if randf() <= 0.5:
		serving_team = teams[0]
	else:
		serving_team = teams[1]
	for team in teams:
		# Team's signals connections
		team.ball_hit.connect(_on_team_ball_hit)
		# Connect own signals to Teams
		self.point_ended.connect(team._on_point_ended)
		self.game_ended.connect(team._on_game_ended)
		self.set_ended.connect(team._on_set_ended)
		self.serve_ended.connect(team._on_serve_ended)
	# Connect UIManager's signals
	update_points_ui.connect(ui_manager.on_update_points)
	# Connect Court's signals
	court.front_side_ball_touch.connect(_on_court_front_side_ball_touch)
	court.back_side_ball_touch.connect(_on_court_back_side_ball_touch)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var children = get_parent().get_children()
	for child in children:
		if is_instance_of(child, Ball):
			var ball_index = child.get_index()
			if not balls_in_game.has(ball_index):
				balls_in_game[ball_index] = child
				child.double_bounce.connect(_on_ball_double_bounce)
	if teams.size() < 2:
		print("ERROR: Need at least to teams to have a valid match")

func _load_dependencies():
	for co_node in get_parent().get_children():
		if is_instance_of(co_node, TeamManager):
			teams.append(co_node)
			co_node.points = 0
		elif is_instance_of(co_node, UIManager):
			ui_manager = co_node
		elif is_instance_of(co_node, Court):
			court = co_node

func go_to_point_ended_state():
	var winning_index = (current_turn_index + 1) % 2
	# End point logic
	# 1. Tell players that the point has ended
	# Gana el jugador a quién no le tocaba, cuando el punto terminó
	var winning_team = teams[winning_index]
	var losing_team = teams[current_turn_index]
	point_ended.emit(winning_team)
	# 2. Show point replay
	# TODO: POINT REPLAY
	# 3. Add point

	# 4. Check if game point
	if last_game_point_played(winning_team, losing_team):
		# TODO: END CURRENT GAME
		go_to_game_ended_state()
	else:
		winning_team.add_point()
		update_points_ui.emit(teams)
		# TODO: TELL PLAYERS to switch to serve state
		go_to_serve_state()

	# 4.	true -> change to game point state
	# 4.	false -> change to serve state

func go_to_game_ended_state():
	pass

func go_to_serve_state():
	for team in teams:
		if team == serving_team:
			team.change_to_serve_state(true)
		else:
			team.change_to_serve_state(false)

func last_game_point_played(winning_team: TeamManager, losing_team: TeamManager) -> bool:
	if winning_team.points == 4 or (winning_team.points == 3 and losing_team.points < 3):
		return true
	return false

func _on_court_front_side_ball_touch():
	pass

func _on_court_back_side_ball_touch():
	pass

func _on_ball_double_bounce(ball: Ball):
	# Add point to correct team
	# Remove ball
	print("Ball eliminar!")
	if balls_in_game.has(ball.get_index()):
		balls_in_game.erase(ball.get_index())
	ball.queue_free()
	# TODO: Avisar quién gano el punto
	go_to_point_ended_state()

func _on_team_ball_hit(hit_direction: int, hit_angle: float, ball: Ball):
	_deprecated_copy_ball_on_hit(ball, hit_direction, hit_angle)

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
