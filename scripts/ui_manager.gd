class_name UIManager
extends Control

var points: Array = [0, 0]
var games: Array = [0, 0]
var sets: Array = [0, 0]

@onready var top_panel: PanelContainer = $HBoxContainer/VSplitContainer/TopPanel
@onready var bottom_panel: PanelContainer = $HBoxContainer/VSplitContainer/BottomPanel

func on_update_points(score: Array[Dictionary]):
	print("UPDATING POINTS!!")
	for i in range(score.size()):
		points[i] = MatchManager.POINTS[score[i]['points']]
		games[i] = score[i]['games']
		sets[i] = score[i]['sets']
	print("POINTS:", points)
	print("GAMES:", games)
	print("SETS:", sets)
	# await (ready)
	_set_labels_text()

# Called when the node enters the scene tree for the first time.
func _ready():
	bottom_panel.ready.connect(_set_labels_text)

func _set_labels_text():
	top_panel.get_node("HBoxContainer/PointsLabel").text = str(points[0])
	top_panel.get_node("HBoxContainer/GamesLabel").text = str(games[0])
	top_panel.get_node("HBoxContainer/SetsLabel").text = str(sets[0])

	bottom_panel.get_node("HBoxContainer/PointsLabel").text = str(points[1])
	bottom_panel.get_node("HBoxContainer/GamesLabel").text = str(games[1])
	bottom_panel.get_node("HBoxContainer/SetsLabel").text = str(sets[1])