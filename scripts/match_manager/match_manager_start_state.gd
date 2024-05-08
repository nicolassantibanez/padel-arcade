class_name MatchManagerStartState
extends MatchManagerState

## State in charge of all the events before the start of a match
## Example: Cut scenes, waiting for loading, etc

func handle_input(_delta: float):
    pass

func update(_delta: float):
    pass

func go_to_serve_state():
    match_manager._state = MatchManagerServeState.new(match_manager)