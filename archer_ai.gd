extends "res://Scene/enemy_base.gd"

@export var too_close_range: float = 150.0
@export var too_far_range : float = 500
@export var shoot_cooldown: float = 2.0

var can_shoot := true
@onready var anim : AnimatedSprite2D = $Sprite2D/Sprite2



func hit_flash():
	super.hit_flash()
	anim.play("hit")



func chase_player(delta : float):
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
	anim.play("shoot")
	await get_tree().create_timer(1.0).timeout
	if state == State.HIT :
		can_shoot = true
		return
	if player == null or state == State.DEAD:
		can_shoot = true
		return

	var arrow = preload("res://Scene/Arrow.tscn").instantiate()
	arrow.global_position = global_position
	arrow.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(arrow)
	if difficulty_multiplier > 1.1 :
		var arrow2 = preload("res://Scene/Arrow.tscn").instantiate()
		arrow2.global_position = global_position
		arrow2.direction = (player.global_position - global_position).normalized()
		await get_tree().create_timer(0.1).timeout
		get_parent().add_child(arrow2)
	anim.play("idle")

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
