extends CharacterBody2D
class_name Player

# Statistiques
@export var speed: float = 400.0
@export var acceleration: float = 15.0
@export var attack_friction: float = 4.0 
@export var health: float

enum Action { NONE, LIGHT, HEAVY, SPIN, DASH, HURT }

var current_action: Action = Action.NONE
var buffered_input: Action = Action.NONE
var direction := Vector2.RIGHT 
var height : float = 0.0 
const GRAVITY := 800.0
const JUMP_FORCE := 500.0
var target_height := 0.0
var vertical_velocity = 0.0

@onready var shadow :Node2D = $Node2D
@onready var sprite : Node2D = $visual
@onready var hurtbox: Area2D = $Hurtbox




# Attack
@export var first_attack: AttackData
@export var first_heavy_attack: AttackData
@export var dive_attack : AttackData
@export var spin_attack : AttackData

var current_attack: AttackData
var attack_velocity := Vector2.ZERO 

# mouse button to attack
var click_attack := false
var charge_attack :=  false
var charge_attack_time : float = 0.5
var charge_attack_hold : float = 0.0

# Hitbox 
@onready var slash_simple_h : PlayerHitbox = $hitbox/Slash_simple
@onready var thrust_h : PlayerHitbox = $hitbox/Thrust
@onready var big_slash_h: PlayerHitbox = $hitbox/BigSlash
@onready var luncher_h: PlayerHitbox = $hitbox/Luncher
@onready var anim: AnimatedSprite2D = $visual/anim
@onready var missile_attack: Missile_box = $hitbox/Missile_attack
@onready var dive: PlayerHitbox = $visual/Dive
@onready var spin: PlayerHitbox = $visual/Spin



var can_spin := true 
var in_windup := false
var dive_s = 1.0

# --- Dégâts / combat ---
var is_invincible := false
var iframe_duration := 0.6
var is_dead := false

var knockback_velocity := Vector2.ZERO
var knockback_friction := 800.0

signal on_death


func _ready() -> void:
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	for  h in   $hitbox.get_children() :
		if h is PlayerHitbox :
			h.player_ref = self
	dive.player_ref = self
	spin.player_ref = self


func _process(_delta: float) -> void:
	sprite.position.y = -height
	var shadow_scale = clamp(1.0 - (height / 200.0), 0.5, 1.0)
	shadow.scale = Vector2(shadow_scale, shadow_scale)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		direction = input_dir

	if current_action == Action.NONE:
		_move_state(input_dir, delta)
		can_spin = true
	elif current_action in [Action.LIGHT, Action.HEAVY]: 
		_attack_state(delta)
	elif current_action == Action.DASH :
		dash(delta)
		can_spin = false
		anim.play("jump")
		if Input.is_action_just_pressed("heavy"):
			current_attack = dive_attack
			current_action = Action.HEAVY
			start_attack()
		elif Input.is_action_just_pressed("light"):
			current_attack = spin_attack
			current_action = Action.LIGHT
			start_attack()
	elif current_action == Action.SPIN :
		velocity = velocity.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
	elif current_action == Action.HURT :
		anim.play("hurt")
		_hurt_state(delta)

	if input_dir.x != 0:
		anim.flip_h = input_dir.x < 0

	if Input.is_action_just_pressed("ui_accept") and height <= 0.0:
		if current_action in [Action.SPIN, Action.HURT] : 
			return
		if current_attack == dive_attack :
			return
		current_action = Action.DASH
		for h  in [slash_simple_h, thrust_h, big_slash_h] :
			h.disable_hitbox()
		vertical_velocity = JUMP_FORCE
		velocity = direction * speed * 1.5
		current_attack = null
		dive_s = 1.0

	vertical_velocity -= GRAVITY * delta * (1.0 if (vertical_velocity > 0  )else 1.6) * dive_s  
	height += vertical_velocity * delta

	if height <= 0.0:
		height = 0.0
		vertical_velocity = 0.0
		if current_action == Action.DASH :
			velocity = velocity.lerp(Vector2.ZERO, delta * 20)
			anim.play("land")
			await get_tree().create_timer(0.2).timeout
			if current_action == Action.DASH and height <= 0 :
				current_action = Action.NONE



	if height > 0 :
		is_invincible = true
	else :
		is_invincible = false

func dash(delta : float ) : 
	velocity = velocity.lerp(Vector2.ZERO, 0.75 * delta)
	move_and_slide()


func _move_state(input_dir: Vector2, delta: float) -> void:
	velocity = velocity.lerp(input_dir * speed, acceleration * delta)
	move_and_slide()

	if input_dir != Vector2.ZERO:
		anim.play("run")
	else:
		anim.play("idle")

func _attack_state(delta: float) -> void:
	attack_velocity = attack_velocity.lerp(Vector2.ZERO, attack_friction * delta)
	velocity = attack_velocity
	move_and_slide()

func _hurt_state(delta: float) -> void:
	velocity = knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	move_and_slide()

# INPUTS 

func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("light"): 
		handle_attack_input(Action.LIGHT)
	elif event.is_action_pressed("heavy"):
		handle_attack_input(Action.HEAVY)

func handle_attack_input(input_type: Action) -> void:
	if current_action == Action.HURT or is_dead:
		return
	if missile_attack.is_active : return
	if current_action == Action.NONE:
		buffered_input = input_type 
		start_attack()
	else:
		buffered_input = input_type



func start_attack() -> void:
	if current_attack == null:
		if buffered_input == Action.LIGHT:
			current_attack = first_attack
		elif buffered_input == Action.HEAVY:
			current_attack = first_heavy_attack
		
		if current_attack == null : return
		current_action = buffered_input # On passe en état de combat
		buffered_input = Action.NONE
	
	
	
	attack_velocity = Vector2.ZERO 
	can_spin = false
	attack_velocity = velocity
	anim.play(current_attack.animation_name)
	
	await _wait(current_attack.windup_duration)
	if current_action not in [Action.HEAVY, Action.LIGHT] : 
		current_attack = null
		return
	
	# ACTIVE
	_apply_attack_effects()
	# impulsion
	attack_velocity = direction * current_attack.lunge_speed 
	await _run_active_phase(current_attack.active_duration)
	if current_action not in [Action.HEAVY, Action.LIGHT] : 
		current_attack = null
		return
	
	
	await _run_recovery(current_attack.recovery_frame)
	if current_action not in [Action.HEAVY, Action.LIGHT] :
		current_attack = null
		return
	
	finish_attack()

func _run_active_phase(duration: float) -> void:
	var timer := 0.0

	while timer < duration:
		if current_attack : 
			if current_attack.animation_name in [&"Dive"] : 
				if  height == 0.0 :
					timer = duration
				else : 
					timer = 0
		else :  
			return
		await get_tree().process_frame
		timer += get_process_delta_time()

func _run_recovery(duration: float) -> void:
	
	if current_attack.animation_name  in [&"Slash1", &"Slash2" ]:
		slash_simple_h.disable_hitbox()
	elif current_attack.animation_name  == &"Thrust" :
		thrust_h.disable_hitbox()
	elif current_attack.animation_name  in [&"Heavy1"]:
		big_slash_h.disable_hitbox()
	elif current_attack.animation_name in [&"Luncher"] :
		luncher_h.disable_hitbox()
		current_action = Action.DASH
		current_attack = null
		return
	elif current_attack.animation_name in [&"Dive"] :
		dive_s = 1.0 
		velocity = Vector2.ZERO
		dive.disable_hitbox()
	elif current_attack.animation_name == &"Spin":
		spin.disable_hitbox()
		dive_s = 1.0
	can_spin = true
	var timer := 0.0
	while timer < duration:
		if missile_attack.is_active :
			return
		elif not current_attack: return
		elif buffered_input != Action.NONE:
			if buffered_input == Action.LIGHT:
				if current_attack.next_light_attack : return
			elif buffered_input == Action.HEAVY:
				if current_attack :
					if  current_attack.next_heavy_attack : return
		
		await get_tree().process_frame
		timer += get_process_delta_time()

func finish_attack() -> void:
	if buffered_input != Action.NONE:
		if missile_attack.is_active : return
		var next_attack: AttackData = null
		if buffered_input == Action.LIGHT:
			next_attack = current_attack.next_light_attack
		elif buffered_input == Action.HEAVY:
			next_attack = current_attack.next_heavy_attack
		
		var next_action = buffered_input 
		buffered_input = Action.NONE
		if  current_attack.animation_name in [&"Spin"] :
			current_attack = null
			current_action = Action.DASH
			return
		if next_attack:
			current_attack = next_attack
			current_action = next_action
			start_attack()
			return
			

	current_action = Action.NONE
	current_attack = null
	attack_velocity = Vector2.ZERO

func _wait(duration: float) -> void:
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout

func _apply_attack_effects() -> void:
	if current_attack.animation_name  in [&"Slash1", &"Slash2" ]:
		slash_simple_h.rotation = direction.angle()
		slash_simple_h.enable_hitbox()
	elif current_attack.animation_name  in [&"Thrust"]:
		thrust_h.rotation = direction.angle()
		thrust_h.enable_hitbox()
	elif current_attack.animation_name  in [&"Heavy1"]:
		big_slash_h.rotation = direction.angle()
		big_slash_h.enable_hitbox()
	elif current_attack.animation_name in [&"Luncher"] :
		vertical_velocity = JUMP_FORCE
		luncher_h.rotation = direction.angle()
		luncher_h.enable_hitbox()
	elif  current_attack.animation_name in [&"Dive"] : 
		dive.enable_hitbox()
		dive_s = 5.0
	elif  current_attack.animation_name in [&"Spin"] :
		velocity.y = 0
		spin.enable_hitbox()
		dive_s = 0.5


func _on_hurtbox_area_entered(area: Area2D) -> void:
	return


func apply_damage(amount: float, source: Node = null, force : float = 300.0) -> void:
	if is_invincible or is_dead:
		return

	health -= amount

	for h in [slash_simple_h, thrust_h, big_slash_h, luncher_h, dive]:
		h.disable_hitbox()
	current_attack = null
	buffered_input = Action.NONE

	if source:
		var dir = (global_position - source.global_position).normalized()
		knockback_velocity = dir * force

	hit_flash()
	start_iframes()

	if health <= 0:
		die()
	else:
		current_action = Action.HURT


func start_iframes() -> void:
	is_invincible = true
	await get_tree().create_timer(iframe_duration).timeout
	is_invincible = false
	if current_action == Action.HURT:
		current_action = Action.NONE


func hit_flash() -> void:
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)


func die() -> void:
	is_dead = true
	current_action = Action.HURT
	velocity = Vector2.ZERO
	on_death.emit()
	# logique de mort à compléter : anim, game over, respawn...


func jump():
	pass
