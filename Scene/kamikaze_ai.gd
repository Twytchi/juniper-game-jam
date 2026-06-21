extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")

var speed = 350
var explode_range = 30.0
var explosion_damage = 20
var explosion_radius = 60.0

enum State {
	CHASE,
	EXPLODE,
	DEAD
}

var state = State.CHASE
var is_exploding = false

func _physics_process(_delta):
	match state:
		State.CHASE:
			chase_player()
		State.EXPLODE:
			velocity = Vector2.ZERO
		State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()


func chase_player():
	var distance = global_position.distance_to(player.global_position)

	if distance <= explode_range:
		state = State.EXPLODE
		explode()
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed

func explode():
	if is_exploding:
		return
	is_exploding = true

	#$AnimationPlayer.play("explode_charge") 
	#await $AnimationPlayer.animation_finished

	var bodies = get_tree().get_nodes_in_group("player")
	for body in bodies:
		if global_position.distance_to(body.global_position) <= explosion_radius:
			body = body as Player
			body.apply_damage(explosion_damage, self)

	state = State.DEAD
	queue_free()
