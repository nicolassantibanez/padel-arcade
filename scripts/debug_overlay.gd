class_name DebugOverlay
extends CanvasLayer

@onready var draw: DebugVector = $DebugDraw3D


func _ready():
	pass
	# if not InputMap.has_action("toggle_debug"):
	# 	InputMap.add_action("toggle_debug")
	# 	var ev = InputEventKey.new()
	# 	ev.scancode = KEY_BACKSLASH
	# 	InputMap.action_add_event("toggle_debug", ev)


func _input(event):
	pass
	# if event.is_action_pressed("toggle_debug"):
	# 	for n in get_children():
	# 		n.visible = not n.visible
