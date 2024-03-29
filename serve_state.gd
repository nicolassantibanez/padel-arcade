extends PlayerState

class_name PlayerServeState

func _init():
    pass

func handle_input(_delta: float, player: Player):
    pass

# Writing _delta instead of delta here prevents the unused variable warning.
func update(_delta: float, player: Player):
    persistent_state.move_and_slide(persistent_state.velocity, Vector2.UP)

func setup(change_state, animated_sprite, persistent_state):
    self.change_state = change_state
    self.animated_sprite = animated_sprite
    self.persistent_state = persistent_state

func move_left():
    pass

func move_right():
    pass