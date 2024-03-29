extends PlayerState

class_name PlayerPlayState

func _init():
    pass

func handle_input(_delta: float, player: Player):
    if Input.is_action_just_pressed("hit_ball_" + str(player.player_id)):
        if player.ball_in_inner_zone:
            print("PERFECT SHOT!")
            # _deprecated_copy_ball_on_hit(ball_to_hit, 0)
            player.ball_hit.emit(player.player_id, player.hitType.PERFECT_HIT, player.ball_to_hit)
            player.label_hit.clear()
            player.label_hit.add_text("PERFECT SHOT!")
        elif player.ball_in_late_zone: # imperfect shot (check if is right or left shot)
            print("TOO LATE!")
            # var rand_angle = randf() * (-PI / 4)
            # _deprecated_copy_ball_on_hit(ball_to_hit, rand_angle)
            player.ball_hit.emit(player.player_id, player.hitType.LATE_HIT, player.ball_to_hit)
            player.label_hit.clear()
            player.label_hit.add_text("TOO LATE!")
        elif player.ball_in_early_zone:
            print("TOO EARLY!")
            # var rand_angle = randf() * PI / 4
            # _deprecated_copy_ball_on_hit(ball_to_hit, rand_angle)
            player.ball_hit.emit(player.player_id, player.hitType.EARLY_HIT, player.ball_to_hit)
            player.label_hit.clear()
            player.label_hit.add_text("TOO EARLY!")
        else:
            player.label_hit.clear()
            player.label_hit.add_text("MISS!")

# Writing _delta instead of delta here prevents the unused variable warning.
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