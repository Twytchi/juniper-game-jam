extends "res://Scene/enemy_base.gd"

@export var enraged_speed: float = 200.0
@export var enraged_threshold: float = 0.4  # passe enraged sous 40% de vie
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var enraged_attack_cooldown: float = 0.5
var damage : float = 5.0
var is_enraged := false
var is_attacking := false

var a_direction : Vector2
func _ready():
	super._ready()
	# speed normal dans l'Inspector, enraged_speed plus élevé


func _physics_process(delta):
	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	else:
		match state:
			State.IDLE:
				idle()
			State.CHASE:
				chase_player(delta)
			State.ATTACK:
				attack()
			State.RECOVER:
				recover()
			State.HIT:
				pass
			State.DEAD:
				velocity = Vector2.ZERO
	
	vertical_velocity -= GRAVITY * delta * (1.0 if (vertical_velocity > 0  )else 1.6)
	height += vertical_velocity * delta
	
	if height > 0 and not is_attacking:
		state = State.HIT
	if height > 0 and is_attacking :
		velocity = a_direction * speed
	
	if height <= 0.0:
		height = 0.0
		height_reached_zero.emit()
		if state == State.HIT :
			state = State.IDLE
	move_and_slide()


func _process(_delta: float) -> void:
	sprite.position.y = -height
	if hurtbox : hurtbox.position.y = -height
	var shadow_scale = clamp(1.0 - (height / 200.0), 0.5, 1.0)
	if shadow : shadow.scale = Vector2(shadow_scale, shadow_scale)
	if height > 0 and not is_attacking:
		sprite.rotation += 10 * _delta 
	else :
		sprite.rotation = 0 


func chase_player(delta : float):
	super.chase_player(delta)
	if player == null:
		return

	_check_enrage()

	if global_position.distance_to(player.global_position) <= attack_range:
		state = State.ATTACK


func _check_enrage():
	var hp_percent = float(current_health) / float(max_health)
	if not is_enraged and hp_percent <= enraged_threshold:
		is_enraged = true
		speed = enraged_speed


func attack():
	if is_attacking:
		return
	is_attacking = true

	velocity = Vector2.ZERO

	# délai avant le coup (télégraphe Phase 2)
	var windup = 0.3 if not is_enraged else 0.15
	await get_tree().create_timer(windup).timeout

	if player == null or state != State.ATTACK:
		is_attacking = false
		return

	# dégâts au contact si toujours à portée
	vertical_velocity = 400 
	a_direction = (player.global_position - global_position).normalized()
	await height_reached_zero
	if player == null or state != State.ATTACK:
		is_attacking = false
		return
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range * 0.5:
		if player.has_method("apply_damage"):
			player.apply_damage(damage, self, 500)

	state = State.RECOVER


func recover():
	velocity = Vector2.ZERO
	if is_attacking == false:
		return

	var cooldown = enraged_attack_cooldown if is_enraged else attack_cooldown
	await get_tree().create_timer(cooldown).timeout

	is_attacking = false
	state = State.CHASE
