class_name PlayerState
extends Node

# --- SIGNALS ---
signal serve_direction_changed(id: int, hit_angle: float, ball: Ball)

@onready var player: Player


func _init(a_player: Player) -> void:
	player = a_player


func handle_process(_delta: float):
	pass


func handle_physics_process(_delta: float):
	pass


func to_receive_state(receive_position: Vector3) -> void:
	player.global_position = Vector3(receive_position.x, receive_position.y, receive_position.z)
	var receive_state = PlayerReceiveState.new(player)
	player.set_state(receive_state)


func to_play_state() -> void:
	var play_state = PlayerPlayState.new(player)
	player.set_state(play_state)


func to_serve_state(serving_position: Vector3, service_hit_angle: float) -> void:
	player.global_position = Vector3(serving_position.x, serving_position.y, serving_position.z)
	# arrow = arrowScene.instantiate()
	# player.add_child(arrow)
	var serve_state = PlayerServeState.new(player, service_hit_angle)
	player.set_state(serve_state)


func to_wait_state(wait_position: Vector3):
	player.global_position = Vector3(wait_position.x, wait_position.y, wait_position.z)
	var wait_state = PlayerWaitState.new(player)
	player.set_state(wait_state)


func to_point_ended_state():
	var point_ended_state = PlayerPointEndedState.new(player)
	player.set_state(point_ended_state)
