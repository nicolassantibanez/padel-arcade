@tool
class_name TeamManager
extends Node3D

signal ball_hit(hit_direction: int, hit_angle: float, ball: Ball)

# Array of Player
var points: int = 0

var players = []

var serving_player_index: int = 0

func add_point():
	points += 1

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

	for child in get_children():
		if is_instance_of(child, Player):
			players.append(child)
	
	if len(players) == 0:
		warnings.append("There must be at least one valid Player as child of this node")

	# Returning an empty array means "no warning".
	return warnings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
