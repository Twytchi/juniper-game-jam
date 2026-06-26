extends Node2D


# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") :
		get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
