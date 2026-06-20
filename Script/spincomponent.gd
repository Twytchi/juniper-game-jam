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

func _physics_process(delta: float) -> void:
	if is_projectile:
		handle_projectile_physics(delta)

# 1. ACCUMULATION DE ROTATION
func add_charge(amount: float):
	if is_spinnable or is_being_spun or is_projectile:
		return
		
	spin_charge += max(0.0, amount - spin_resistance)
	
	if spin_charge >= 100.0:
		is_spinnable = true


func get_grabbed():
	is_spinnable = false
	is_being_spun = true
	current_throw_power = 500.0 # Puissance de base
	
	if body:

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
	

func handle_projectile_physics(delta: float):
	if not body: return
	body.velocity = throw_velocity 
	body.move_and_slide()


func stop_projectile():
	is_projectile = false
	spin_charge = 0.0
	
	if body:
		body.set_physics_process(true)
