@tool
class_name TeamManager
extends Node3D

# Array of Player
var _players = []

# Use setters to update the configuration warning automatically.
func _get_configuration_warnings():
	var warnings = []

	for child in get_children():
		if is_instance_of(child, Player):
			_players.append(child)
	
	if len(_players) == 0:
		warnings.append("There must be at least one valid Player as child of this node")

	# Returning an empty array means "no warning".
	return warnings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
