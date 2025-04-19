class_name PlayerPlayState
extends PlayerState


func _init(a_player: Player):
	super(a_player)


func handle_process(_delta: float):
	player.free_input()


func handle_physics_process(delta: float):
	player.normal_movement(delta)
