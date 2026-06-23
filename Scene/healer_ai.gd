extends EnemyBase

@export var heal_range: float = 150.0
@export var heal_amount: int = 10
@export var heal_cooldown: float = 3.0
@export var flee_range: float = 200.0

var can_heal := true
var heal_target: EnemyBase = null


func chase_player(_delta: float = 0.0):
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

	# on stocke tout ce dont on a besoin avat les await
	var amount = heal_amount
	var cooldown = heal_cooldown

	await get_tree().create_timer(0.5).timeout

	if is_instance_valid(target):
		target.current_health = min(
			target.current_health + amount,
			target.max_health
		)

	await get_tree().create_timer(cooldown).timeout
	can_heal = true
