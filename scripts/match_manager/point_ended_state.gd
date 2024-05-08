class_name MatchManagerPointEndedState
extends MatchManagerState

var service_count: int = 1

func _init(a_match_manager: MatchManager):
    print("IN MM POINT ENDED STATE!!!")
    match_manager = a_match_manager
    # Avisarle a los jugadores que el punto terminó y vemos si el juego terminó
    var total_points: int = match_manager.get_total_played_points()
    var serving_positions = match_manager.court.get_serving_positions(total_points)
    for i in range(len(match_manager.teams)):
        var team: TeamManager = match_manager.teams[i]
        var serving_pos = serving_positions[i]
        if team == match_manager.serving_team:
            team.change_to_serve_state(true, serving_pos)
        else:
            team.change_to_serve_state(false, serving_pos)

func handle_input(_delta: float):
    pass

func update(_delta: float):
    pass

func failed_service():
    service_count += 1
    if service_count > 2:
        match_manager._state = MatchManagerPointEndedState.new(match_manager)

func on_court_steel_ball_touch(ball_bounces: int):
    if ball_bounces < 3:
        match_manager.foul(match_manager.FoulType.OUT)
        if service_count == 1:
            match_manager.second_service()
        else:
            match_manager.go_to_point_ended_state()

func on_court_front_side_ball_touch():
    if match_manager.current_turn_index == 0 and match_manager.serving_team_index == 1: # front turn de recibir
        # todo gucci
        pass
    else: # match_manager.current_turn_index == 1 and match_manager.serving_team_index == 0: # back turn de recibir
        match_manager.foul(match_manager.FoulType.OUT)
        # Ir a second service
        if service_count == 1:
            match_manager.second_service()
        else:
            match_manager.go_to_point_ended_state()

func on_court_back_side_ball_touch():
    if match_manager.current_turn_index == 1 and match_manager.serving_team_index == 0: # front turn de recibir
        # todo gucci
        pass
    else: # match_manager.current_turn_index == 0 and match_manager.serving_team_index == 1: # back turn de recibir
        match_manager.foul(match_manager.FoulType.OUT)
        # Ir a second service
        if service_count == 1:
            match_manager.second_service()
        else:
            match_manager.go_to_point_ended_state()