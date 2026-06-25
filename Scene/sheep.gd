extends EnemyBase

var d := 0.0
var direction_change_timer := 0.0
var is_recovering := false

func _ready():
	super._ready()

	if difficulty_multiplier == 0.0:
		spin_component.add_charge(100.0)

	pick_new_direction()


func pick_new_direction():
	d = randf_range(0.0, 360.0)
	direction_change_timer = randf_range(2.0, 6.0)


func chase_player(delta):

	direction_change_timer -= delta

	if direction_change_timer <= 0:
		state = State.RECOVER

	var direction = Vector2.RIGHT.rotated(deg_to_rad(d))

	velocity = direction * speed

func recover():
	velocity = Vector2.ZERO
	if is_recovering:
		return
	is_recovering = true

	await get_tree().create_timer(randf_range(0.6, 1.5)).timeout

	is_recovering = false
	pick_new_direction()
	state = State.CHASE
