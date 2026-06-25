extends Node2D




func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/chapter_selection_menu.tscn")


func _on_option_pressed() -> void:
	pass



func _on_quit_pressed() -> void:
	get_tree()
