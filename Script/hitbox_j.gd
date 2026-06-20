extends Area2D
class_name PlayerHitbox

@onready var collision_shape : CollisionShape2D= $CollisionShape2D
@onready var sprite : Node2D = $Sprite2D

func enable_hitbox():
	collision_shape.set_deferred("disabled", false)
	if not sprite : return
	sprite.show()
	

func disable_hitbox():
	collision_shape.set_deferred("disabled", true)
	if not sprite : return
	sprite.hide()
