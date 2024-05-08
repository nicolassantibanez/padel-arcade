extends PlayerState

class_name PlayerWaitState

# var player: Player
func _init(a_player: Player, wait_position: Vector3):
    print("Player", a_player.player_id, ": IN WAIT STATE!")
    var player = a_player
    player.global_position = Vector3(wait_position.x, wait_position.y, wait_position.z)