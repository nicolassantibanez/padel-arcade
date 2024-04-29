class_name UIManager
extends Control

var points: Array[int] = [0, 0]

@onready var l1: Label = $HBoxContainer/VSplitContainer/TopPanel/Label
@onready var l2: Label = $HBoxContainer/VSplitContainer/BottomPanel/Label2

func on_update_points(teams: Array[TeamManager]):
	for i in range(teams.size()):
		points[i] = teams[i].points

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	l1.text = "P1: " + str(points[0])
	l2.text = "P2: " + str(points[1])
