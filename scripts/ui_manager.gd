@tool
class_name UIManager
extends Control

var points: Array = [0, 0]
var games: Array = [0, 0]
var sets: Array = [0, 0]
var match_manager: MatchManager

@onready var top_panel: PanelContainer = $GridContainer/BottomContainer/VSplitContainer/TopPanel
@onready
var bottom_panel: PanelContainer = $GridContainer/BottomContainer/VSplitContainer/BottomPanel
@onready var fault_label: Label = $GridContainer/BottomContainer/HBoxContainer3/FaultLabel


## Use setters to update the configuration warning automatically.
func _get_configuration_warnings():
	var warnings = []

	for co_node in get_parent().get_children():
		if is_instance_of(co_node, match_manager):
			match_manager = co_node

	if not match_manager:
		warnings.append("MatchManager is missing in the scene tree!")

	return warnings


func on_update_points(score: Array[Dictionary]):
	print("UPDATING POINTS!!")
	for i in range(score.size()):
		points[i] = MatchManager.POINTS[score[i]["points"]]
		games[i] = score[i]["games"]
		sets[i] = score[i]["sets"]
	print("POINTS:", points)
	print("GAMES:", games)
	print("SETS:", sets)
	# await (ready)
	_set_labels_text()


func on_match_manager_fault_called(fault: MatchManager.FaultType):
	match fault:
		MatchManager.FaultType.OUT:
			fault_label.text = "Fault: OUT"
		MatchManager.FaultType.DOUBLE_BOUNCE:
			fault_label.text = "Fault: DOUBLE BOUNCE"
	await get_tree().create_timer(2).timeout
	fault_label.text = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	_load_dependencies()
	fault_label.text = ""
	bottom_panel.ready.connect(_set_labels_text)
	_connect_match_manager_signals()


func _set_labels_text():
	top_panel.get_node("HBoxContainer/PointsLabel").text = str(points[0])
	top_panel.get_node("HBoxContainer/GamesLabel").text = str(games[0])
	top_panel.get_node("HBoxContainer/SetsLabel").text = str(sets[0])

	bottom_panel.get_node("HBoxContainer/PointsLabel").text = str(points[1])
	bottom_panel.get_node("HBoxContainer/GamesLabel").text = str(games[1])
	bottom_panel.get_node("HBoxContainer/SetsLabel").text = str(sets[1])


func _connect_match_manager_signals():
	match_manager.fault_called.connect(on_match_manager_fault_called)


func _load_dependencies():
	for co_node in get_parent().get_children():
		if is_instance_of(co_node, MatchManager):
			match_manager = co_node
