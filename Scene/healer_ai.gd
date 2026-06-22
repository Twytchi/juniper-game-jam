extends CharacterBody2D


@export var heal_range: float = 150.0
@export var heal_amount: int = 10
@export var heal_countdwon: float = 3.0
@export var flee_range: float = 200.0

var can_heal := true
var heal_target : EnemyBase = null

@onready var player = get_tree().get_first_node_in_group("player")

func chase_player():
	_find_heal_target()
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= flee_range:
		_flee()
		return
	
	if heal_target != null and can_heal:
		_move_toward_target()
		if global_position.distance_to(heal_target.global_position) <= heal_range:
			heal(heal_target)
		return


	velocity = Vector2.ZERO


func _find_heal_target():
	heal_target = null
	var lowest_hp_percent := 1.0
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy == self:
			continue
		if enemy is EnemyBase and enemy.state != EnemyBase.State.DEAD:
			var hp_percent = float(enemy.current_health) / float(enemy.max_health)
			if hp_percent < lowest_hp_percent:
				lowest_hp_percent = hp_percent
				heal_target = enemy
	
	if lowest_hp_percent >= 0.8:
		heal_target = null 


func _flee():
	var flee_direction = (global_position - player.global_position).normalized()
	velocity = flee_direction * speed


func _move_toward_target():
	if heal_target == null:
		return
	var direction = (heal_target.global_position - global_position).normalized()
	velocity = direction * speed


func heal(target: EnemyBase):
	if not can_heal:
		return
	can_heal = false

	velocity = Vector2.ZERO

	# délai de cast (télégraphe Phase 2)
	await get_tree().create_timer(0.5).timeout

	if target == null or not is_instance_valid(target) or state == State.DEAD:
		can_heal = true
		return

	target.current_health = min(
		target.current_health + heal_amount,
		target.max_health
	)

	await get_tree().create_timer(heal_cooldown).timeout
	can_heal = true
