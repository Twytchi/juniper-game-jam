extends PlayerHitbox
class_name Missile_box

var timer_counter: float = 0.0
var is_winding_up: bool = false
var is_active: bool = false
const WINDUP_DURATION: float = 0.3
var missile : SpinComponent
@export var player : Player
@onready var point: Marker2D = $Sprite2D/point
@onready var digger : Polygon2D = $Sprite2D


func _physics_process(delta: float) -> void:
	if is_winding_up:
		timer_counter += delta
		if timer_counter >= WINDUP_DURATION:
			is_winding_up = false
			activate_missile()

	if Input.is_action_just_pressed("missile"):
		if not player.can_spin :
			return
		is_winding_up = true
		player.current_action = player.Action.SPIN
		player.current_attack = null
		for h  in [player.slash_simple_h, player.thrust_h, player.big_slash_h] :
				h.disable_hitbox()
		timer_counter = 0.0

	if Input.is_action_just_released("missile"):
		stop_missile()

	if is_active : 
		if missile :
			missile.charge_spin(delta)
			missile.body.global_position = point.global_position
			if player.direction :
				rotation = lerp(rotation, player.direction.angle(), delta * 10)

func activate_missile():
	is_active = true
	enable_hitbox()

func stop_missile():
	is_winding_up = false
	is_active = false
	timer_counter = 0.0
	disable_hitbox()
	if missile : 
		missile.throw(Vector2.RIGHT.rotated(rotation))
	missile = null 
	player.current_action = player.Action.NONE

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox : 
		var e = area.get_parent() as CharacterBody2D
		for s in  e.get_children() :
			if s is SpinComponent :
				
				if not s.is_spinnable :
					return
				missile = s
				missile.get_grabbed()
				look_at(missile.global_position)
				missile.body.global_position = point.global_position
				break
