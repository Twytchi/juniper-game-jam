extends "res://Scene/enemy_base.gd"

# --- Dash ---
@export var dash_speed: float = 1000.0
@export var dash_range: float = 300.0
@export var dash_duration: float = 0.35
@export var dash_damage_n_knock := Vector2(1.0, 400.0)

# --- Shoot ---
@export var too_close_range: float = 150.0
@export var shoot_cooldown: float = 0.7
var can_shoot := true

# --- Jump / Enrage ---
@export var enraged_speed: float = 500.0
@export var enraged_threshold: float = 0.4 
@export var attack_range: float = 400.0
@export var recover_duration: float = 0.5


var damage : float = 5.0
var is_enraged := false
var is_attacking := false
var a_direction : Vector2

@onready var hitbox: EnemyHitbox = $Hitbox
@onready var anim : AnimatedSprite2D = $Sprite2D/Sprite2

func _ready():
	super._ready() 
	SoundManager.musique_player.stream = SoundManager.boss_music 
	SoundManager.musique_player.play()

func _process(delta: float) -> void:
	super._process(delta)
	_check_enrage()
	
	anim.flip_h = (velocity.x < 0)
	sprite.position.y = -height
	if hurtbox: hurtbox.position.y = -height
	
	var shadow_scale = clamp(1.0 - (height / 200.0), 0.5, 1.0)
	if shadow: shadow.scale = Vector2(shadow_scale, shadow_scale)
	
	if height > 0 and not is_attacking:
		sprite.rotation += 10 * delta 
	else:
		sprite.rotation = 0 

func _physics_process(delta):
	if is_dead :
		state =State.DEAD
	
	
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
				attack() # Le cerveau du boss
			State.RECOVER:
				recover()
			State.HIT:
				pass
			State.DEAD:
				velocity = Vector2.ZERO
	
	vertical_velocity -= GRAVITY * delta * (1.0 if (vertical_velocity > 0) else 1.6)
	height += vertical_velocity * delta
	
	if height > 0 and not is_attacking:
		state = State.HIT
	if height > 0 and is_attacking:
		velocity = a_direction * speed * 1.6
	
	if height <= 0.0:
		height = 0.0
		height_reached_zero.emit()
		if state == State.HIT:
			state = State.IDLE
			
	move_and_slide()


func chase_player(delta: float):
	super.chase_player(delta)
	if player == null: return
	
	# Passe en mode attaque si le joueur est assez proche
	if global_position.distance_to(player.global_position) <= dash_range:
		state = State.ATTACK
		
	anim.play("walk")

# --- LE CERVEAU DES ATTAQUES ---
func attack():
	if is_attacking or player == null:
		return
		
	var distance = global_position.distance_to(player.global_position)
	
	# Choix de l'attaque selon la distance
	if distance <= attack_range and randf() > 0.5:
		dash_attack()
	elif distance > too_close_range and can_shoot and randf() > 0.5: 
		# Mix entre tir et dash à mi-distance (50% de chance si le tir est dispo)
		shoot()
	else:
		jump_attack()


func dash_attack():
	is_attacking = true
	velocity = Vector2.ZERO
	anim.play("charge")
	await get_tree().create_timer(0.5).timeout

	if player == null: 
		end_attack()
		return

	var dash_direction = (player.global_position - global_position).normalized()
	hitbox.data = dash_damage_n_knock
	hitbox.look_at(global_position + dash_direction)
	hitbox.enable_hitbox()
	
	velocity = dash_direction * dash_speed
	anim.play("dash")
	await get_tree().create_timer(dash_duration).timeout

	hitbox.disable_hitbox()
	end_attack()


func jump_attack():
	is_attacking = true
	velocity = Vector2.ZERO

	var windup = 0.1 if is_enraged else 0.3
	await get_tree().create_timer(windup).timeout

	if player == null:
		end_attack()
		return

	vertical_velocity = 400 
	a_direction = (player.global_position - global_position).normalized()
	
	await height_reached_zero
	
	if player != null and global_position.distance_to(player.global_position) <= attack_range * 0.35 :
		if player.has_method("apply_damage"):
			player.apply_damage(damage, self, 500)

	end_attack()


func shoot():
	is_attacking = true
	can_shoot = false
	
	await get_tree().create_timer(1.0).timeout
	
	if state != State.HIT and state != State.DEAD and player != null:
		var dir = (player.global_position - global_position).normalized()
		_spawn_arrow(dir)
		
		if randf() > 0.5 :
			await get_tree().create_timer(0.15).timeout
			if player != null: _spawn_arrow((player.global_position - global_position).normalized())
		
	anim.play("idle")
	end_attack()
	
	# Gère le cooldown du tir séparément
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true


func _spawn_arrow(dir: Vector2):
	var arrow = preload("res://Scene/arrow.tscn").instantiate()
	arrow.global_position = global_position
	arrow.direction = dir
	get_parent().add_child(arrow)


# --- FONCTIONS UTILITAIRES ---
func end_attack():
	is_attacking = false
	state = State.RECOVER

func recover():
	velocity = Vector2.ZERO
	anim.play("idle")
	# On utilise is_attacking comme sécurité pour ne pas boucler dans recover
	if not is_attacking:
		is_attacking = true 
		await get_tree().create_timer(recover_duration).timeout
		is_attacking = false
		state = State.CHASE

func start_iframes():
	hitbox.disable_hitbox()
	super.start_iframes()

func _check_enrage():
	if is_enraged or max_health <= 0: return
	var hp_percent = float(current_health) / float(max_health)
	if hp_percent <= enraged_threshold:
		is_enraged = true
		speed = enraged_speed


func die():
	state = State.DEAD
	anim.play("dead")
	on_death.emit()
	vertical_velocity = 200
	await height_reached_zero
	anim.play("boom")
	await get_tree().create_timer(0.2).timeout
	queue_free()
