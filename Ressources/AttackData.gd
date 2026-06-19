class_name AttackData
extends Resource

@export var animation_name : StringName

@export_group("Combo")
@export var next_light_attack: AttackData
@export var next_heavy_attack: AttackData

@export_group("Stats")
@export var damage: float
@export var spin_power : float
@export var poise_damage : float
@export var knockback : float
@export var lunge_speed: float = 10.0

#timer
@export_group("Timer")
@export var windup_duration : float 
@export var active_duration : float
@export var recovery_frame :  float
