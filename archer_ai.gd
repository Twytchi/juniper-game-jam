extends "res://Scene/enemy_base.gd"

@export var too_close_range: float = 150.0
@export var too_far_range : float = 300
@export var shoot_cooldown: float = 10.0

var can_shoot := true


func chase_player():
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()

	if distance <= too_close_range:
		velocity = -direction * speed
	elif distance >= too_far_range:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	if can_shoot:
		shoot()


func shoot():
	can_shoot = false

	await get_tree().create_timer(0.4).timeout

	if player == null or state == State.DEAD:
		can_shoot = true
		return

	var arrow = preload("res://Scene/Arrow.tscn").instantiate()
	arrow.global_position = global_position
	arrow.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(arrow)

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
