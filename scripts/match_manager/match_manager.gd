@tool
class_name MatchManager
extends Node3D

signal update_points_ui(score: Array[Dictionary])
signal point_ended(winning_team: TeamManager)
signal game_ended
signal set_ended
signal match_ended
signal serve_ended(new_ball: Ball)

const ball_scene: Resource = preload ("res://scenes/ball.tscn")
const POINTS = {
	0: 0,
	1: 15,
	2: 30,
	3: 40,
	4: "ADV"
}

enum FaultType {DOUBLE_BOUNCE, OUT}
enum State {PAUSE, PLAY}

var teams: Array[TeamManager] = []
var score: Array[Dictionary] = [
	{
		"points": 0,
		"games": 0,
		"sets": 0,
	},
	{
		"points": 0,
		"games": 0,
		"sets": 0,
	}
]
var serving_team: TeamManager
var serving_team_index: int

## Stores the index of Team that has the current turn
## End of turn: when team hits the ball or the point ends
var current_turn_index: int
var last_turn_index: int
var ui_manager: UIManager
var court: Court
var current_ball: Ball
var is_serving = false
var is_second_service: bool = false
var hit_net_on_service = false
var ball_in_hitter_side = true

var balls_in_game = {}

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
	_load_dependencies()
	if randf() <= 0.5:
		serving_team = teams[0]
		serving_team_index = 0
	else:
		serving_team = teams[1]
		serving_team_index = 1
	for team in teams:
		# Team's signals connections
		team.ball_hit.connect(_on_team_ball_hit)
		team.service_hit.connect(_on_team_service_hit)
		# Connect own signals to Teams
		self.point_ended.connect(team._on_point_ended)
		self.game_ended.connect(team._on_game_ended)
		self.set_ended.connect(team._on_set_ended)
		self.serve_ended.connect(team._on_serve_ended)
	# Connect UIManager's signals
	update_points_ui.connect(ui_manager.on_update_points)
	# Connect Court's signals
	# court.front_side_ball_touch.connect(_on_court_front_side_ball_touch)
	# court.back_side_ball_touch.connect(_on_court_back_side_ball_touch)
	# court.steel_ball_touch.connect(_on_court_steel_ball_touch)

	# Como lo puse como último nodo, espero a que esté listo para poder empezar
	court.ready.connect(start_game)

# Function that initiates the match/game
func start_game():
	_serve_setup()

# Put players into positions for a new service
func _serve_setup():
	hit_net_on_service = false
	var total_points: int = get_total_played_points()
	var serving_positions = court.get_serving_positions(total_points)
	for i in range(len(teams)):
		var team: TeamManager = teams[i]
		var serving_pos = serving_positions[i]
		if team == serving_team:
			current_turn_index = i
			team.change_to_serve_state(true, serving_pos)
		else:
			team.change_to_serve_state(false, serving_pos)

func _load_dependencies():
	for co_node in get_parent().get_children():
		if is_instance_of(co_node, TeamManager):
			teams.append(co_node)
			co_node.points = 0
		elif is_instance_of(co_node, UIManager):
			ui_manager = co_node
		elif is_instance_of(co_node, Court):
			court = co_node

## Function that manages the logic when a point ends
func go_to_point_ended(winning_team: TeamManager, losing_team: TeamManager):
	print("POINT ENDED!")
	# 1. Tell players that the point has ended
	point_ended.emit(winning_team)
	# 2. Show point replay
	# TODO: POINT REPLAY

	# 3. Check if is game point
	if last_game_point_played(winning_team, losing_team): # END CURRENT GAME
		go_to_game_ended()
	else: # Continue current GAME
		if losing_team.points == 4: # If losing team with ADV
			losing_team.lose_point()
		else: # Add point to winning team
			winning_team.add_point()
		_update_points()
		_serve_setup() # Notify Players to switch to serve state

func go_to_second_service():
	_serve_setup()

func _update_points():
	for i in range(len(teams)):
		score[i]['points'] = teams[i].points
	update_points_ui.emit(score)

## Manages the logic when a GAME ends
func go_to_game_ended():
	# Agregar game point al equipo que lo ganó
	var winner_index: int = get_team_index_game_winner()
	score[winner_index]['games'] += 1
	# Reset current game points
	for team in teams:
		team.points = 0
	_update_points()

	# TODO: Cambiar de lado, cuando sean juegos impares!
	# Switch serving Team
	serving_team_index = next_team_index(serving_team_index)
	serving_team = teams[serving_team_index]
	_serve_setup()

func next_team_index(current_index: int) -> int:
	return (current_index + 1) % 2

func get_team_index_game_winner() -> int:
	var winner_index: int = 0
	var p: int = 0
	for i in range(len(teams)):
		var team = teams[i]
		if team.points > p:
			winner_index = i
			p = team.points
	return winner_index

func get_total_played_points() -> int:
	var total: int = 0
	for team in teams:
		total = total + team.points
	return total

func last_game_point_played(winning_team: TeamManager, losing_team: TeamManager) -> bool:
	if winning_team.points == 4 or (winning_team.points == 3 and losing_team.points < 3):
		return true
	return false

## Passes the turn to the next Team
func _end_current_team_turn():
	last_turn_index = current_turn_index
	# current_turn_index = (current_turn_index + 1) % 2
	current_turn_index = -1

func _on_team_ball_hit(hit_direction: int, hit_angle: float, ball_hit: Ball):
	ball_in_hitter_side = true
	print("(hitmoment) hitter_side? ", ball_in_hitter_side)
	is_serving = false
	_end_current_team_turn()
	# create_new_ball(ball_hit.global_position, false, hit_direction, hit_angle)
	# ball_hit.queue_free()
	redirect_ball(hit_direction, hit_angle, ball_hit)

func redirect_ball(hit_direction: int, hit_angle: float, ball: Ball):
	# _end_current_team_turn()
	ball.reset_bounce_count()
	ball.is_serve_ball = false
	ball.direction = Vector3(0, 0.3, hit_direction).rotated(Vector3.UP, hit_angle)
	ball.target_velocity = ball.direction * ball.speed
	_connect_to_ball_signals(current_ball)

## Callback function when the serving team plays it's service
## 
## - Create new serve Ball
## - Notify every team that the service has been played
func _on_team_service_hit(hit_direction: int, hit_angle: float, ball_pos: Vector3):
	ball_in_hitter_side = true
	is_serving = true
	_end_current_team_turn()
	var new_ball: Ball = create_new_ball(ball_pos, true, hit_direction, hit_angle)
	serve_ended.emit(new_ball)

## Creates a new ball for the match
## returns the new ball instance
func create_new_ball(ball_pos: Vector3, is_serve: bool, hit_direction: int, hit_angle: float) -> Ball:
	var ball_instance: Node = ball_scene.instantiate()
	ball_instance.position = ball_pos + Vector3(0, 0, hit_direction)
	ball_instance.is_serve_ball = is_serve
	current_ball = ball_instance
	ball_instance.direction = Vector3(0, 0.3, hit_direction).rotated(Vector3.UP, hit_angle)
	add_child(ball_instance)
	_connect_to_ball_signals(current_ball)
	return ball_instance

func _connect_to_ball_signals(ball: Ball):
	ball.ground_bounce.connect(_on_ball_ground_bounce)
	ball.wall_bounce.connect(_on_ball_wall_bounce)
	ball.fence_bounce.connect(_on_ball_fence_bounce)
	ball.net_bounce.connect(_on_ball_net_bounce)
	ball.cross_side.connect(_on_ball_cross_side)

func _on_ball_ground_bounce(ball: Ball):
	if is_serving:
		print("Ball is serrving!!")
		if ball_in_hitter_side: # cayó en el mismo lado
			print("Cayó en el mismo lado :cccc")
			call_fault(ball, FaultType.OUT)
			return
		else: # cayó en lado correcto
			if ball.bounces_count == 1 and not court.ball_hit_serving_zone(ball.global_position):
				print("FUERA DEL SERVICE BOX")
				call_fault(ball, FaultType.OUT)
				return
			elif ball.bounces_count >= 1 and hit_net_on_service:
				hit_net_on_service = false
				print("NET! Repeat Service")
				go_to_second_service() # repeat service
				return
	print("Floor bounce count: ", ball.floor_bounce_count)
	if ball_in_hitter_side:
		print("OWN SIDE BOUNCE!")
		call_fault(ball, FaultType.OUT)
		return
	if ball.floor_bounce_count == 2:
		call_fault(ball, FaultType.DOUBLE_BOUNCE)

func _on_ball_wall_bounce(ball: Ball):
	print("Bounce count: ", ball.bounces_count)
	print("Ball in hitter side: ", ball_in_hitter_side)
	if ball.bounces_count == 1:
		if not ball_in_hitter_side: # Pelota cruzó, y ya golpeó el último turno
			call_fault(ball, FaultType.OUT)

func _on_ball_fence_bounce(ball: Ball):
	if ball.bounces_count == 1: # No importa si la pelota cruza o no, siempre el primero choque con reja es falta
		call_fault(ball, FaultType.OUT)

func _on_ball_net_bounce(_ball: Ball):
	if is_serving:
		hit_net_on_service = true

func _on_ball_cross_side():
	print("BALLL CROSSED SIDE!!!!!")
	ball_in_hitter_side = false
	current_turn_index = next_team_index(last_turn_index)
	# start receiver turn

func call_fault(ball: Ball, fault: FaultType):
	print("FAULT!")
	ball.disable_detector()
	if is_serving and fault != FaultType.DOUBLE_BOUNCE:
		print("INVALID SERVE!")
		if is_second_service:
			is_second_service = false
			go_to_point_ended(teams[next_team_index(serving_team_index)], serving_team)
		else:
			print("SECOND SERVICE!")
			is_second_service = true
			go_to_second_service()
	else:
		match fault:
			FaultType.OUT:
				go_to_point_ended(teams[next_team_index(last_turn_index)], teams[last_turn_index])
			FaultType.DOUBLE_BOUNCE:
				go_to_point_ended(teams[last_turn_index], teams[next_team_index(last_turn_index)])

	ball.queue_free()