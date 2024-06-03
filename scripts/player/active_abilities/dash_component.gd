class_name DashComponent
extends ActiveAbilityComponent

@export var dash_speed: float = 15

@onready var timer: Timer = $Timer
@onready var cooldown_timer: Timer = $CooldownTimer

var can_dash: bool = true

const COOLDOWN_SECS = 3

func _ready():
    cooldown_timer.wait_time = COOLDOWN_SECS
    cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
    timer.timeout.connect(_on_timer_timeout)

func activate():
    if player_owner and uses > 0:
        uses -= 1
        print("Uses left: ", uses)
        player_owner.speed = dash_speed
        timer.start()
        cooldown_timer.start()

func _on_timer_timeout():
    player_owner.speed = player_owner.default_speed

func _on_cooldown_timer_timeout():
    uses += 1
    print("Charged up! Uses left: ", uses)
    if uses < max_uses:
        cooldown_timer.start()