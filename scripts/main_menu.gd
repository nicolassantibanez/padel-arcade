extends Control

@onready var play_btn: Button = $MarginContainer/VBoxContainer/Play
@onready var options_btn: Button = $MarginContainer/VBoxContainer/Options
@onready var quit_btn: Button = $MarginContainer/VBoxContainer/QuitGame
@onready var buttons: Array[Button] = [
	play_btn,
	options_btn,
	quit_btn,
]
@onready var play_sound: AudioStreamPlayer = $PlaySound
@onready var select_sound: AudioStreamPlayer = $SelectSound

var match_scene = "res://scenes/main.tscn"

func _ready():
	play_btn.pressed.connect(_on_play_btn_pressed)
	options_btn.pressed.connect(_on_options_btn_pressed)
	quit_btn.pressed.connect(_on_quit_btn_pressed)
	for btn in buttons:
		btn.focus_entered.connect(_on_btn_focus_entered)
		btn.mouse_entered.connect(_on_btn_focus_entered)

func _on_btn_focus_entered():
	select_sound.play(0.18)

func _on_play_btn_pressed():
	play_sound.play()
	await play_sound.finished
	get_tree().change_scene_to_file(match_scene)

func _on_options_btn_pressed():
	pass

func _on_quit_btn_pressed():
	get_tree().quit()