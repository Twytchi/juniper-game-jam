extends EnemyBase

var dash_speed = 400.0
var dash_range = 150.0
var dash_duration = 0.2
var recover_duration = 1.0

var is_dashing = false
var is_recovering = false

func _ready():
	super._ready()


func chase_player():
	super.chase_player()
	if global_position.distance_to(player.global_position) <= dash_range:
		state = State.ATTACK


func attack():
	if is_dashing:
		return
	is_dashing = true

	var dash_direction = (player.global_position - global_position).normalized()
	velocity = dash_direction * dash_speed

	await get_tree().create_timer(dash_duration).timeout

	is_dashing = false
	state = State.RECOVER


func recover():
	velocity = Vector2.ZERO
	if is_recovering:
		return
	is_recovering = true

	await get_tree().create_timer(recover_duration).timeout

	is_recovering = false
	state = State.CHASE
