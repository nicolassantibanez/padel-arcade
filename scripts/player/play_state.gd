extends PlayerState

class_name PlayerPlayState

func _init():
    pass

func handle_input(_delta: float, player: Player):
    if Input.is_action_just_pressed("hit_ball_" + str(player.player_id)):
        player.label_hit.clear()
        if player.ball_in_inner_zone:
            var hit_angle = 0
            player.ball_hit.emit(player.player_id, hit_angle, player.ball_to_hit)
            player.label_hit.add_text("PERFECT SHOT!")
            print("PERFECT SHOT!")
        elif player.ball_in_late_zone: # Early shot -> to the left
            var hit_angle = randf() * (-PI / 4)
            player.ball_hit.emit(player.player_id, hit_angle, player.ball_to_hit)
            player.label_hit.add_text("TOO LATE!")
            print("TOO LATE!")
        elif player.ball_in_early_zone: # Early shot -> to the right
            var hit_angle = randf() * PI / 4
            player.ball_hit.emit(player.player_id, hit_angle, player.ball_to_hit)
            player.label_hit.add_text("TOO EARLY!")
            print("TOO EARLY!")
        else:
            player.label_hit.add_text("MISS!")

func update(delta: float, player: Player):
    var direction = Vector3.ZERO

    # We check for each move input and update the direction accordingly
    if Input.is_action_pressed("move_right_" + str(player.player_id)):
        direction.x += 1
    if Input.is_action_pressed("move_left_" + str(player.player_id)):
        direction.x -= 1
    if Input.is_action_pressed("move_back_" + str(player.player_id)):
        direction.z += 1
    if Input.is_action_pressed("move_forward_" + str(player.player_id)):
        direction.z -= 1

    if direction != Vector3.ZERO: # Si nos estamos moviendo
        direction = direction.normalized()
        player.animation_player.play("Walk")
        # Setting the basis property will affect the rotation of the node.
        player.pivot.basis = Basis.looking_at(direction)
    else: # No moving
        player.animation_player.play("Idle")

    # Ground Velocity
    player.target_velocity.x = direction.x * player.speed
    player.target_velocity.z = direction.z * player.speed

    # Vertical velocity
    if not player.is_on_floor(): # Falls when not on the ground
        player.target_velocity.y = player.target_velocity.y - (player.fall_acceleration * delta)

    # Moving Character
    player.velocity = player.target_velocity
    player.move_and_slide()