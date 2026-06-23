class_name SpinComponent
extends Node2D

@export var body : CharacterBody2D
@export var spin_resistance := 0.0
@export var max_throw_speed := 1500.0

# États du composant
@export var spin_charge := 0.0
@export var is_spinnable := false
var is_being_spun := false
var is_projectile := false
@export var body_sprite : Node2D 
# Variables pour le lancer
var throw_velocity := Vector2.ZERO
var current_throw_power := 0.0
@export var spin_thresold := 60.0

# Gestionnaire de l'animation de flash
var flash_tween: Tween

@export var hitbox : EnemyHitbox

func _ready() -> void:
	if hitbox : hitbox.disable_hitbox()


func _physics_process(delta: float) -> void:
	if is_projectile:
		handle_projectile_physics(delta)
	if is_spinnable:
		pass


func set_is_spinnable(value: bool) -> void:
	if is_spinnable == value:
		return
	
	is_spinnable = value
	

	if not body_sprite:
		return
		
	if is_spinnable:
		start_flash_animation()
	else:
		stop_flash_animation()

func start_flash_animation() -> void:
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	

	flash_tween = create_tween().set_loops()
	

	flash_tween.tween_property(body_sprite, "modulate", Color(1, 1, 1, 0.3), 0.2)

	flash_tween.tween_property(body_sprite, "modulate", Color(1, 1, 1, 1), 0.2)

func stop_flash_animation() -> void:
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()

	if body_sprite:
		body_sprite.modulate = Color(1, 1, 1, 1)

func add_charge(amount: float):
	if is_spinnable or is_being_spun or is_projectile:
		return
		
	spin_charge += max(0.0, amount - spin_resistance)
	
	if spin_charge >= spin_thresold:
		set_is_spinnable(true)


func get_grabbed():
	is_spinnable = false
	is_being_spun = true
	current_throw_power = 500.0 # Puissance de base
	
	if body:
		body.velocity = Vector2.ZERO
		body.set_physics_process(false) 



func charge_spin(delta: float):
	if is_being_spun:
	
		current_throw_power = min(current_throw_power + 1000.0 * delta, max_throw_speed)
	if body_sprite :
		body_sprite.rotation += delta * current_throw_power / 100 

func throw(direction: Vector2):
	is_being_spun = false
	is_projectile = true
	throw_velocity = direction.normalized() * current_throw_power
	hitbox.enable_hitbox()
	body.set_collision_layer_value(2, false)

func handle_projectile_physics(delta: float):
	if not body: return
	body.velocity = throw_velocity 
	if body.is_on_wall() or body.is_on_ceiling() or body.is_on_floor() :
		stop_projectile()
	body.move_and_slide()


func stop_projectile():
	set_is_spinnable(false)
	is_projectile = false
	spin_charge = 0.0
	stop_flash_animation()
	
	if body:
		body_sprite.rotation = 0
		body.set_physics_process(true)
		if body is EnemyBase:
			body as EnemyBase
			body.current_health -= 45
			body.vertical_velocity = 500
			hitbox.disable_hitbox()
