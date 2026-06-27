extends Node2D

@export var level_scene_path : String = "res://Scene/levels/level_"

func _ready() -> void:
	var level_num = 1
	for child in $Button.get_children():
		if child is TextureButton:

			child.pressed.connect(func(): _on_level_button_pressed(level_num))
			
			child.pivot_offset = child.size / 2
			

			child.mouse_entered.connect(func(): _on_button_hover(child))
			child.mouse_exited.connect(func(): _on_button_unhover(child))
			
			level_num += 1


func _on_level_button_pressed(level_index: int) -> void:
	var full_path = level_scene_path + str(level_index) + ".tscn"
	
	if ResourceLoader.exists(full_path):
		SoundManager.musique_player.stream = SoundManager.music_combat
		SoundManager.musique_player.play()
		ScoreManager.multiplier = 1.0
		ScoreManager.score = 0 
		ScoreManager.action_history.clear()
		get_tree().change_scene_to_file(full_path)
	else:
		print("Erreur : La scène n'existe pas -> ", full_path)

func _on_button_hover(button: TextureButton) -> void:
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_button_unhover(button: TextureButton) -> void:
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
