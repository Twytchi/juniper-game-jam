extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
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
		for area in get_overlapping_areas():
			if area.is_in_group("hurtbox") and area.get_parent().has_method("apply_damage"):
				area.get_parent().apply_damage(damage, self)
		_destroy()
		return

	if travel_distance >= max_distance:
		_destroy()


func get_damage() -> int:
	return damage


func _destroy():
	if is_done:
		return
	is_done = true
	queue_free()
