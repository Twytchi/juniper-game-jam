extends Area2D

const KAMIKAZE  = preload("res://Scene/kamikaze_ai.tscn")
const ARCHER    = preload("res://Scene/archer_ai.tscn")
const DASHER    = preload("res://Scene/dasher_ai.tscn")
const BERSERKER = preload("res://Scene/berserker_ai.tscn")
const HEALER    = preload("res://Scene/healer_ai.tscn")

@export var enemies_to_spawn: Array = [KAMIKAZE, ARCHER]

var already_triggered := false
var spawn_points := []


func _ready():
	body_entered.connect(_on_body_entered)
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)


func _on_body_entered(body):
	if already_triggered:
		return
	if not body.is_in_group("player"):
		return

	already_triggered = true

	for i in enemies_to_spawn.size():
		var enemy = enemies_to_spawn[i].instantiate()
		# utilise les markers dans l'ordre, boucle si moins de markers que d'ennemis
		var spawn = spawn_points[i % spawn_points.size()]
		enemy.global_position = spawn.global_position
		get_parent().add_child(enemy)
