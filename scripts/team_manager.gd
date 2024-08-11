@tool
class_name TeamManager
extends Node3D
## Representas a Team on Padel Match.
##
## It manages all it's team players and throws signals to communicate their actions.

## -- SIGNALS ---
signal ball_hit(hit_direction: int, hit_angle: float, ball: Ball)
signal ball_hit_power(hit_angle: float, ball: Ball, power: float)
signal service_hit(hit_direction: int, hit_angle: float, ball_pos: Vector3)
signal turn_ended

## Keeps the count of their own current game points
var points: int = 0

## Array with all the [Player]s in the team
var players: Array[Player] = []

## Index of the [Player] whose turn is to serve
var serving_player_index: int = 0

## Checks if the team currently is serving
var is_team_serving: bool = false

## The direction where the Team is hitting to
var hit_direction: int

## The current angle the serving [Player] has to serve to
var service_hit_angle: float

## Checks if the team can hit the ball
var turn_to_hit: bool


# Use setters to update the configuration warning automatically.
func _get_configuration_warnings():
	var warnings = []

	players = _load_players()

	if players.size() == 0:
		warnings.append("There must be at least one valid Player as child of this node")

	# Returning an empty array means "no warning".
	return warnings


# Called when the node enters the scene tree for the first time.
func _ready():
	_load_players()
	# Connect player's signals
	for p in players:
		p.ball_hit.connect(_on_player_ball_hit)
		p.ball_hit_power.connect(_on_player_ball_hit_power)
		p.service_hit.connect(_on_player_service_hit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func add_point():
	points += 1


func lose_point():
	points -= 1


## Changes all it's [Player] state to [ServeState]
func change_to_serve_state(turn_to_serve: bool, serving_zone: Dictionary):
	is_team_serving = turn_to_serve
	hit_direction = serving_zone["hit_direction"]
	service_hit_angle = serving_zone["hit_angle"]
	for i in range(len(players)):
		var player = players[i]
		if is_team_serving:
			if i == serving_player_index:
				player.change_to_serve_state(serving_zone["server_pos"])
			else:
				player.change_to_wait_state(serving_zone["teammate_pos"])
		else:
			if i == serving_player_index:
				player.change_to_receive_state(serving_zone["server_pos"])
			else:
				player.change_to_wait_state(serving_zone["teammate_pos"])


## Manages what happens when a point has ended
## Changes all it's [Player] state to [PointEndedState]
func on_point_ended(winning_team: TeamManager):
	var won = false
	if winning_team == self:
		won = true
	for p in players:
		p.change_to_point_ended_state(won)


## Manages what happens when the current game has ended
## TODO: Complete this function
func on_game_ended():
	pass


## Manages what happens when the current set has ended
## TODO: Complete this function
func on_set_ended():
	pass


## Manages what happens when a serve has ended
## Changes all it's [Player] state to [PlayState]
func on_serve_ended(new_ball: Ball):
	for player in players:
		player.change_to_play_state(new_ball)


## Populates the team players array
## By searching for child [Player] nodes
func _load_players() -> Array[Player]:
	for child in get_children():
		if is_instance_of(child, Player):
			players.append(child)
	return players


## Callback function when a [Player] hits a ball with power
func _on_player_ball_hit_power(
	_player_id: int, ball: Ball, shot_speed: float, lift_angle: float, rotation_angle: float
):
	if not turn_to_hit:
		return
	turn_ended.emit()
	var lifted_vector = Vector3(0, 0, self.hit_direction).rotated(Vector3.RIGHT, lift_angle)
	var shot_direction = lifted_vector.rotated(Vector3.UP, rotation_angle).normalized()
	ball.redirect(shot_direction, shot_speed)


## Callback function when a [Player] hits a ball
func _on_player_ball_hit(_player_id: int, hit_angle: float, ball: Ball):
	ball_hit.emit(hit_direction, hit_angle, ball)


## Callback function when a [Player] serves
func _on_player_service_hit(serving_player: Player):
	# NEEDS:
	# - Hit LEFT or RIGHT (depending court side and serving side)
	# - HIT DIRECTION: should be a variable that should be updated by the match manager
	if players[serving_player_index].player_id == serving_player.player_id:
		var hit_angle = service_hit_angle
		service_hit.emit(hit_direction, hit_angle, serving_player.global_position + Vector3.UP)
	# _deprecated_copy_ball_on_hit(ball, hit_direction, hit_angle)
