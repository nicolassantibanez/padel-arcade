extends PlayerState

class_name PlayerReceiveState

# var player: Player
func _init(a_player: Player, receive_position: Vector3):
    print("Player", a_player.player_id, ": IN RECEIVE STATE!")
    var player = a_player
    player.global_position = Vector3(receive_position.x, receive_position.y, receive_position.z)

func handle_input(_delta: float, player: Player):
    player.free_input()

func update(delta: float, player: Player):
    player.normal_movement(delta)