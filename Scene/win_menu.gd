extends Node2D

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://Scene/chapter_selection_menu.tscn")


func _ready() -> void:
	$comboUi._update_ui(ScoreManager.score, ScoreManager.multiplier)
