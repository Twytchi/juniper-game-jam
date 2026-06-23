extends Area2D
class_name EnemyHitbox


var data : Vector2 
@export var missile_data : AttackData 

func _ready() -> void:
	area_entered.connect(on_hitbox_area_entered)

func enable_hitbox():
	monitoring = true
	set_deferred("monitorable", true)


func disable_hitbox():
	monitoring = false
	set_deferred("monitorable", false)
	visible = false 

func point_at(angle : Vector2 ):
	rotation = angle.angle()

func on_hitbox_area_entered(area : Area2D) :
	if area is Hurtbox :
		if area.get_parent() is Player :
			var p : Player = area.get_parent()
			p.apply_damage(data.x, self, data.y)
		elif area.get_parent() is EnemyBase :
			var e : EnemyBase = area.get_parent()
			if e  == get_parent()  : return
			if not missile_data : return
			e.apply_damage(missile_data, self)
			e.vertical_velocity = 650
