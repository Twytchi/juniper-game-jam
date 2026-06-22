extends "res://Scene/enemy_base.gd"

@export var enraged_speed: float = 200.0
@export var enraged_threshold: float = 0.4  # passe enraged sous 40% de vie
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var enraged_attack_cooldown: float = 0.5

var is_enraged := false
var is_attacking := false


func _ready():
	super._ready()
	# speed normal dans l'Inspector, enraged_speed plus élevé


func chase_player():
	super.chase_player()
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

	if player == null or state == State.DEAD:
		is_attacking = false
		return

	# dégâts au contact si toujours à portée
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range * 1.5:
		if player.has_method("apply_damage"):
			player.apply_damage(10, self)

	state = State.RECOVER


func recover():
	velocity = Vector2.ZERO
	if is_attacking == false:
		return

	var cooldown = enraged_attack_cooldown if is_enraged else attack_cooldown
	await get_tree().create_timer(cooldown).timeout

	is_attacking = false
	state = State.CHASE
