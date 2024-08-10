extends PlayerState

class_name PlayerPlayState


func _init():
	pass


func handle_input(_delta: float, player: Player):
	player.free_input()


func update(delta: float, player: Player):
	player.normal_movement(delta)
