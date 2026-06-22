extends "res://Scene/enemy_base.gd"

@export var dash_speed: float = 400.0
@export var dash_range: float = 150.0
@export var dash_duration: float = 0.2
@export var recover_duration: float = 1.0

var is_dashing := false
var is_recovering := false


func chase_player():
	super.chase_player()
	if player == null:
		return
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
