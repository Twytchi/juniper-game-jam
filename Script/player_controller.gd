extends CharacterBody2D
class_name Player

# Statistiques
@export var speed: float = 350.0
@export var acceleration: float = 15.0
@export var attack_friction: float = 5.0 
@export var health: float

enum Action { NONE, LIGHT, HEAVY, SPIN, DASH, HURT }

var current_action: Action = Action.NONE
var buffered_input: Action = Action.NONE
var direction := Vector2.RIGHT 

# Attack
@export var first_attack: AttackData
var current_attack: AttackData
var attack_velocity := Vector2.ZERO 

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		direction = input_dir

	if current_action == Action.NONE:
		_move_state(input_dir, delta)
	elif current_action in [Action.LIGHT, Action.HEAVY]: 
		_attack_state(delta)

func _move_state(input_dir: Vector2, delta: float) -> void:
	# Mouvement normal fluide
	velocity = velocity.lerp(input_dir * speed, acceleration * delta)
	move_and_slide()

func _attack_state(delta: float) -> void:
	# Le fameux amortissement ! La vitesse d'attaque retombe à zéro progressivement.
	attack_velocity = attack_velocity.lerp(Vector2.ZERO, attack_friction * delta)
	velocity = attack_velocity
	move_and_slide()

# --- INPUTS ---

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

# --- SYSTEME D'ATTAQUE ---

func start_attack() -> void:
	if current_attack == null:
		current_attack = first_attack
		current_action = buffered_input # On passe en état de combat
		buffered_input = Action.NONE
	
	attack_velocity = Vector2.ZERO 
	
	# PHASE 1 : WINDUP
	await _wait(current_attack.windup_duration)
	
	# PHASE 2 : ACTIVE
	_apply_attack_effects()
	# On donne le grand coup de pied au cul (l'impulsion) directionnel !
	attack_velocity = direction * current_attack.lunge_speed 
	await _run_active_phase(current_attack.active_duration)
	
	# PHASE 3 : RECOVERY
	await _run_recovery(current_attack.recovery_frame)
	
	finish_attack()

func _run_active_phase(duration: float) -> void:
	var timer := 0.0
	while timer < duration:
		await get_tree().process_frame
		timer += get_process_delta_time()

func _run_recovery(duration: float) -> void:
	var timer := 0.0
	while timer < duration:
		# Plus besoin de recalculer les inputs ici, le _physics_process le fait !
		if buffered_input != Action.NONE:
			return # Cancel magique
		await get_tree().process_frame
		timer += get_process_delta_time()

func finish_attack() -> void:
	if buffered_input != Action.NONE:
		var next_attack: AttackData = null
		if buffered_input == Action.LIGHT:
			next_attack = current_attack.next_light_attack
		elif buffered_input == Action.HEAVY:
			next_attack = current_attack.next_heavy_attack
		
		var next_action = buffered_input # Sauvegarde l'action pour la machine à état
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
	print("Impact !")


func take_damage(amount : int ) :
	pass

func die():
	pass

func jump():
	pass
