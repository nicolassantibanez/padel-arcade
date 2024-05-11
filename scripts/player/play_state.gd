extends PlayerState

class_name PlayerPlayState

func _init(a_player: Player, new_ball: Ball):
    print("PLAYER-", a_player.player_id, " in PLAY STATE!")
    # var player = a_player
    a_player.playing_ball = new_ball

func handle_input(_delta: float, player: Player):
    player.free_input()

func update(delta: float, player: Player):
    player.normal_movement(delta)