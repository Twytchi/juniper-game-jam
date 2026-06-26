extends Node2D

@onready var visu_2: Node2D = $visu2 # On référence le parent pour le fade global
@onready var perso: AnimatedSprite2D = $visu2/perso
@onready var fond: AnimatedSprite2D = $visu2/fond

var color1 := ["red", "blue", "green"]
var color2 := ["green", "red", "blue"] 
var c_paronama : int = 0

var vitesses_perso := [2.0, 2.5, -2.0] 
var vitesses_fond := [-0.5, -1.0, 1.5] 

var vitesse_perso_actuelle: float
var vitesse_fond_actuelle: float

var perso_start_x: float
var fond_start_x: float

func _ready() -> void:
	perso_start_x = perso.position.x
	fond_start_x = fond.position.x
	
	vitesse_perso_actuelle = vitesses_perso[0]
	vitesse_fond_actuelle = vitesses_fond[0]
	
	perso.play(color1[0])
	fond.play(color2[0])
	SoundManager.musique_player.stream = SoundManager.menu_music
	SoundManager.musique_player.play()

func _process(delta: float) -> void:
	$visu1/Wheel.rotation -= 0.2 * delta
	
	perso.position.x += vitesse_perso_actuelle * delta
	fond.position.x += vitesse_fond_actuelle * delta

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/chapter_selection_menu.tscn")

func _on_option_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

func change_fond_pers():
	c_paronama = (c_paronama + 1) % color1.size()
	
	# --- SÉQUENCE DE FADE VIA TWEEN ---
	var tween = create_tween()
	
	# 1. Disparition (0.4 seconde)
	tween.tween_property(visu_2, "modulate:a", 0.0, 0.4)
	
	# 2. On change les textures et positions SANS que le joueur le voie
	tween.tween_callback(func():
		perso.play(color1[c_paronama])
		fond.play(color2[c_paronama])
		
		vitesse_perso_actuelle = vitesses_perso[c_paronama]
		vitesse_fond_actuelle = vitesses_fond[c_paronama]
		
		perso.position.x = perso_start_x
		fond.position.x = fond_start_x
	)
	
	# 3. Apparition (0.4 seconde)
	tween.tween_property(visu_2, "modulate:a", 1.0, 0.4)

func _on_timer_timeout() -> void:
	change_fond_pers()
