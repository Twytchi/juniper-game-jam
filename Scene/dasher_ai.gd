extends "res://Scene/enemy_base.gd"

@export var dash_speed: float = 500.0
@export var dash_range: float = 400.0
@export var dash_duration: float = 0.4
@export var recover_duration: float = 1.0
@export var dash_damage_n_knock := Vector2(1.0, 400.0) #le x cest les dégats les y c le knockback

var is_dashing := false
var is_recovering := false

@onready var hitbox: EnemyHitbox = $Hitbox


func chase_player():
	super.chase_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= dash_range:
		state = State.ATTACK
	hitbox.data = dash_damage_n_knock


func attack():
	if is_dashing:
		return
	is_dashing = true
	velocity= Vector2.ZERO
	await  get_tree().create_timer(0.5).timeout

	var dash_direction = (player.global_position - global_position).normalized()
	hitbox.look_at(dash_direction)
	hitbox.enable_hitbox()
	velocity = dash_direction * dash_speed

	await get_tree().create_timer(dash_duration).timeout

	is_dashing = false
	hitbox.disable_hitbox()
	state = State.RECOVER


func recover():
	velocity = Vector2.ZERO
	if is_recovering:
		return
	is_recovering = true

	await get_tree().create_timer(recover_duration).timeout

	is_recovering = false
	state = State.CHASE
