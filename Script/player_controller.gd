extends CharacterBody2D
class_name Player

# Statistiques
@export var speed: float = 300.0
@export var acceleration: float = 15.0
@export var attack_friction: float = 4.0 
@export var health: float

enum Action { NONE, LIGHT, HEAVY, SPIN, DASH, HURT }

var current_action: Action = Action.NONE
var buffered_input: Action = Action.NONE
var direction := Vector2.RIGHT 
var height : float = 0.0 
const GRAVITY := 800.0
const JUMP_FORCE := 400.0
var target_height := 0.0
var vertical_velocity = 0.0

@onready var shadow :Node2D = $Node2D
@onready var sprite : Sprite2D = $Sprite2D




# Attack
@export var first_attack: AttackData
@export var first_heavy_attack: AttackData

var current_attack: AttackData
var attack_velocity := Vector2.ZERO 


# Hitbox 
@onready var slash_simple_h : PlayerHitbox = $hitbox/Slash_simple
@onready var thrust_h : PlayerHitbox = $hitbox/Thrust
@onready var big_slash_h: PlayerHitbox = $hitbox/BigSlash
@onready var luncher_h: PlayerHitbox = $Sprite2D/Luncher



var can_spin := true 
var in_windup := false


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
	elif current_action == Action.SPIN :
		velocity = velocity.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()

	if Input.is_action_just_pressed("ui_accept") and height <= 0.0:
		if current_action in [Action.SPIN, Action.HURT] : 
			return
		current_action = Action.DASH
		for h  in [slash_simple_h, thrust_h] :
			h.disable_hitbox()
		vertical_velocity = JUMP_FORCE
		velocity = direction * speed * 1.5
		current_attack = null

	vertical_velocity -= GRAVITY * delta * (1.0 if (vertical_velocity > 0 ) else 1.6)
	height += vertical_velocity * delta

	if height <= 0.0:
		height = 0.0
		vertical_velocity = 0.0
		if current_action == Action.DASH :
			current_action = Action.NONE
			velocity = Vector2.ZERO



func dash(delta : float ) : 
	velocity = velocity.lerp(Vector2.ZERO, 0.75 * delta)
	move_and_slide()


func _move_state(input_dir: Vector2, delta: float) -> void:
	velocity = velocity.lerp(input_dir * speed, acceleration * delta)
	move_and_slide()

func _attack_state(delta: float) -> void:
	attack_velocity = attack_velocity.lerp(Vector2.ZERO, attack_friction * delta)
	velocity = attack_velocity
	move_and_slide()

# INPUTS 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light"): 
		handle_attack_input(Action.LIGHT)
	elif event.is_action_pressed("heavy"):
		handle_attack_input(Action.HEAVY)

func handle_attack_input(input_type: Action) -> void:
	if current_action == Action.NONE:
		buffered_input = input_type # On stocke le type de la toute première attaque
		start_attack()
	else:
		buffered_input = input_type

#     SYSTEME D'ATTAQUE 

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
	#  WINDUP
	await _wait(current_attack.windup_duration)
	if current_action not in [Action.HEAVY, Action.LIGHT] : return
	
	# ACTIVE
	_apply_attack_effects()
	# impulsion
	attack_velocity = direction * current_attack.lunge_speed 
	await _run_active_phase(current_attack.active_duration)
	if current_action not in [Action.HEAVY, Action.LIGHT] : return
	
	# RECOVERY
	
	await _run_recovery(current_attack.recovery_frame)
	if current_action not in [Action.HEAVY, Action.LIGHT] : return
	
	finish_attack()

func _run_active_phase(duration: float) -> void:
	var timer := 0.0
	while timer < duration:
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
	
	can_spin = true
	var timer := 0.0
	while timer < duration:
		
		if buffered_input != Action.NONE:
			if buffered_input == Action.LIGHT:
				if current_attack.next_light_attack : return
			elif buffered_input == Action.HEAVY:
				if  current_attack.next_heavy_attack : return
		await get_tree().process_frame
		timer += get_process_delta_time()

func finish_attack() -> void:
	if buffered_input != Action.NONE:
		var next_attack: AttackData = null
		if buffered_input == Action.LIGHT:
			next_attack = current_attack.next_light_attack
		elif buffered_input == Action.HEAVY:
			next_attack = current_attack.next_heavy_attack
		
		var next_action = buffered_input 
		buffered_input = Action.NONE
		
		if next_attack:
			current_attack = next_attack
			current_action = next_action
			start_attack()
			return
			
	# Reset total si le combo est fini
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
		luncher_h.enable_hitbox()


func take_damage(amount : int ) :
	pass

func die():
	pass

func jump():
	pass
