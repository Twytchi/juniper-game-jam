extends "res://Scene/enemy_base.gd"

@export var dash_speed: float = 900.0
@export var dash_range: float = 400.0
@export var dash_duration: float = 0.3
@export var recover_duration: float = 1.0
@export var dash_damage_n_knock := Vector2(1.0, 400.0) #le x cest les dégats les y c le knockback

var is_dashing := false
var is_recovering := false

@onready var hitbox: EnemyHitbox = $Hitbox
@onready var anim : AnimatedSprite2D = $Sprite2D/Sprite2

func _ready():
	super._ready() 
	dash_duration *= difficulty_multiplier
	recover_duration = 1.0 - (difficulty_multiplier - 1.2)

func _process(_delta: float) -> void:
	super._process(_delta)
	anim.flip_h = (velocity.x > 0  )

func chase_player(delta : float):
	super.chase_player(delta )
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= dash_range:
		state = State.ATTACK
	hitbox.data = dash_damage_n_knock
	anim.play("walk")


func attack():
	if is_dashing:
		return
	is_dashing = true
	velocity= Vector2.ZERO
	anim.play("charge")
	await  get_tree().create_timer(1.0).timeout

	var dash_direction = (player.global_position - global_position).normalized()
	hitbox.look_at(dash_direction)
	hitbox.enable_hitbox()
	velocity = dash_direction * dash_speed
	anim.play("dash")
	await get_tree().create_timer(dash_duration).timeout

	is_dashing = false
	hitbox.disable_hitbox()
	state = State.RECOVER


func recover():
	velocity = Vector2.ZERO
	if is_recovering:
		return
	is_recovering = true
	anim.play("idle")
	await get_tree().create_timer(recover_duration).timeout

	is_recovering = false
	state = State.CHASE


func die():
	state = State.DEAD
	on_death.emit()
	is_dashing = false
	is_recovering = false
	vertical_velocity = 400
	await height_reached_zero
	anim.play("boom")
	await get_tree().create_timer(0.2).timeout
	queue_free()

func start_iframes():
	hitbox.disable_hitbox()
	super.start_iframes()
