class_name MatchManagerState
extends Node2D

var match_manager: MatchManager

func _init(a_match_manager: MatchManager):
    match_manager = a_match_manager

func update(_delta: float):
    pass

func failed_service():
    pass

func on_court_steel_ball_touch(ball_bounces: int):
    pass

func on_ball_invalid_serve():
    pass

func on_ball_double_bounce():
    pass

func on_court_front_side_ball_touch():
    pass

func on_court_back_side_ball_touch():
    pass

func go_to_serve_state():
    pass

func go_to_point_state():
    pass

func go_to_end_point_state():
    pass

func go_to_end_game_state():
    pass

func go_to_end_set_state():
    pass

func go_to_end_match_state():
    pass