class_name AbilityComponent
extends Node3D

@export var player_owner: Player:
	set(v):
		player_owner = v
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not player_owner:
		warnings.append("Missing Player reference!")
	return warnings


func activate():
	pass
