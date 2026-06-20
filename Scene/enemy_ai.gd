extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")

var speed = 100

enum State {
	CHASE,
	IDLE,
	ATTACK,
	DEAD
}

var state = State.CHASE


func _physics_process(_delta):
	match state:
		State.CHASE:
			chase_player()
		State.IDLE:
			idle()
		State.ATTACK:
			attack()
		State.DEAD:
			die()

	move_and_slide()


func chase_player():
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed


func idle():
	velocity = Vector2.ZERO


func attack():
	velocity = Vector2.ZERO



func die():
	velocity = Vector2.ZERO
