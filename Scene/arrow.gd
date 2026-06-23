extends Area2D

@export var speed: float = 300.0
@export var damage: float = 2.0
@export var arc_height: float = 80.0

var direction := Vector2.ZERO
var height: float = 0.0
var vertical_velocity: float = 0.0
const GRAVITY := 300.0
var travel_distance: float = 0.0
var max_distance: float = 800.0
var is_done := false


func _ready():
	vertical_velocity = sqrt(2.0 * GRAVITY * arc_height)
	area_entered.connect(on_hitbox_area_entered)


func _physics_process(delta):
	if is_done:
		return

	var move = direction * speed * delta
	position += move
	travel_distance += move.length()

	vertical_velocity -= GRAVITY * delta
	height += vertical_velocity * delta

	if has_node("Sprite2D"):
		$Sprite2D.position.y = -height

	if height <= 0.0:
		height = 0.0
		_destroy()
		return

	if travel_distance >= max_distance:
		_destroy()


func get_damage() -> float:
	return damage


func _destroy():
	if is_done:
		return
	is_done = true
	queue_free()

func on_hitbox_area_entered(area : Area2D) :
			if area is Hurtbox :
				if area.get_parent() is Player :
					var p : Player = area.get_parent()
					p.apply_damage(damage, self, 400)
