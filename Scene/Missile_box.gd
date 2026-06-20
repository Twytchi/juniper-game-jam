extends PlayerHitbox

var timer_counter: float = 0.0
var is_winding_up: bool = false
var is_active: bool = false
const WINDUP_DURATION: float = 0.5

func _physics_process(delta: float) -> void:
	if is_winding_up:
		timer_counter += delta
		if timer_counter >= WINDUP_DURATION:
			is_winding_up = false
			activate_missile()

	if Input.is_action_just_pressed("missile"):
		is_winding_up = true
		timer_counter = 0.0

	if Input.is_action_just_released("missile"):
		stop_missile()

func activate_missile():
	is_active = true
	enable_hitbox()

func stop_missile():
	is_winding_up = false
	is_active = false
	timer_counter = 0.0
	disable_hitbox()
