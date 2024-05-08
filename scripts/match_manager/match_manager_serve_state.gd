class_name MatchManagerServeState
extends MatchManagerState

var service_count: int = 1

func _init(a_match_manager: MatchManager):
	print("IN MM SERVING STATE!!!")
	match_manager = a_match_manager
	# Avisarle a los jugadores que tienen que servir
	serve_setup()

func handle_input(_delta: float):
	pass

func update(_delta: float):
	pass

func serve_setup():
	var total_points: int = match_manager.get_total_played_points()
	var serving_positions = match_manager.court.get_serving_positions(total_points)
	for i in range(len(match_manager.teams)):
		var team: TeamManager = match_manager.teams[i]
		var serving_pos = serving_positions[i]
		if team == match_manager.serving_team:
			team.change_to_serve_state(true, serving_pos)
		else:
			team.change_to_serve_state(false, serving_pos)

func on_ball_double_bounce():
	match_manager.go_to_point_ended()

func on_ball_invalid_serve():
	failed_service()

func go_to_serve_state():
	match_manager._state = MatchManagerServeState.new(match_manager)

func failed_service():
	service_count += 1
	if service_count > 2:
		match_manager.go_to_point_ended()
	else:
		serve_setup()
