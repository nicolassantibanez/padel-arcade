@tool
class_name TeamManager
extends Node3D

signal ball_hit(hit_direction: int, hit_angle: float, ball: Ball)

var points: int = 0

var players: Array[Player] = []

var serving_player_index: int = 0

func add_point():
	points += 1

func change_to_serve_state(won: bool):
	for p in players:
		p.change_to_serve_state(won)

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
	pass

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _load_players() -> Array[Player]:
	for child in get_children():
		if is_instance_of(child, Player):
			players.append(child)
	return players

func _on_player_ball_hit(player_id: int, hit_angle: float, ball: Ball):
	var hit_direction: int = -1
	print("Player_id:", player_id)
	if player_id == 2:
		hit_direction = 1
	ball_hit.emit(hit_direction, hit_angle, ball)
	# _deprecated_copy_ball_on_hit(ball, hit_direction, hit_angle)