@tool
class_name TeamManager
extends Node3D

signal ball_hit(hit_direction: int, hit_angle: float, ball: Ball)
signal service_hit(hit_direction: int, hit_angle: float, ball_pos: Vector3)

var points: int = 0

var players: Array[Player] = []

var serving_player_index: int = 0

var is_team_serving: bool = false
var hit_direction: int

func add_point():
	points += 1

func lose_point():
	points -= 1

func change_to_serve_state(turn_to_serve: bool, serving_zone: Dictionary):
	print("IN team: ", self, "change_to_serve_state")
	is_team_serving = turn_to_serve
	hit_direction = serving_zone["hit_direction"]
	for i in range(len(players)):
		var player = players[i]
		if is_team_serving:
			if i == serving_player_index:
				player.change_to_serve_state(serving_zone['server_pos'])
			else:
				player.change_to_wait_state(serving_zone['teammate_pos'])
		else:
			if i == serving_player_index:
				player.change_to_receive_state(serving_zone['server_pos'])
			else:
				player.change_to_wait_state(serving_zone['teammate_pos'])

func _on_point_ended(winning_team: TeamManager):
	var won = false
	if winning_team == self:
		won = true
	for p in players:
		p.change_to_point_ended_state(won)

func _on_game_ended():
	pass
func _on_set_ended():
	pass
func _on_serve_ended():
	for player in players:
		player.change_to_play_state()

# Use setters to update the configuration warning automatically.
func _get_configuration_warnings():
	var warnings = []

	players = _load_players()
	
	if players.size() == 0:
		warnings.append("There must be at least one valid Player as child of this node")

	# Returning an empty array means "no warning".
	return warnings

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_players()
	# Connect player's signals
	for p in players:
		p.ball_hit.connect(_on_player_ball_hit)
		p.service_hit.connect(_on_player_service_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _load_players() -> Array[Player]:
	for child in get_children():
		if is_instance_of(child, Player):
			players.append(child)
	return players

func _on_player_ball_hit(_player_id: int, hit_angle: float, ball: Ball):
	ball_hit.emit(hit_direction, hit_angle, ball)
	# _deprecated_copy_ball_on_hit(ball, hit_direction, hit_angle)

func _on_player_service_hit(serving_player: Player):
	# NEEDS:
		# - Hit LEFT or RIGHT (depending court side and serving side)
		# - HIT DIRECTION: should be a variable that should be updated by the match manager
	if players[serving_player_index].player_id == serving_player.player_id:
		var hit_angle = PI / 8
		service_hit.emit(hit_direction, hit_angle, serving_player.global_position + Vector3.UP)
	# _deprecated_copy_ball_on_hit(ball, hit_direction, hit_angle)
