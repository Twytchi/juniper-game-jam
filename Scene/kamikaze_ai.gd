extends "res://Scene/enemy_base.gd"

var attack_range = 30.0
var explosion_damage = 20.0
var explosion_radius = 60.0
var is_attacking = false


func chase_player():
	super.chase_player()
	if global_position.distance_to(player.global_position) <= attack_range:
		state = State.ATTACK


func attack():
	if is_attacking:
		return
	is_attacking = true

	velocity = Vector2.ZERO

	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("explode")
		await $AnimationPlayer.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout

	for body in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(body.global_position) <= explosion_radius:
			if body.has_method("apply_damage"):
				body.apply_damage(explosion_damage, self)

	die()
