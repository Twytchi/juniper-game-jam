extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")

var chase_speed = 120
var dash_speed = 400
var dash_range = 150.0
var dash_duration = 0.2
var cooldown_duration = 1.0

enum State {
	CHASE,
	DASH,
	COOLDOWN,
	DEAD
}

var state = State.CHASE


func _physics_process(_delta):
	match state:
		State.CHASE:
			chase_player()
		State.DASH:
			pass  # vitesse déjà fixée dans start_dash()
		State.COOLDOWN:
			velocity = Vector2.ZERO
		State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()


func chase_player():
	var distance = global_position.distance_to(player.global_position)

	if distance <= dash_range:
		start_dash()
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * chase_speed


func start_dash():
	state = State.DASH
	var dash_direction = (player.global_position - global_position).normalized()
	velocity = dash_direction * dash_speed

	await get_tree().create_timer(dash_duration).timeout
	start_cooldown()


func start_cooldown():
	state = State.COOLDOWN
	await get_tree().create_timer(cooldown_duration).timeout
	state = State.CHASE
