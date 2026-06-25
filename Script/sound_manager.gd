extends Node

var volume_musique : float = 0.5
var volume_sfx : float = 1.0

@onready var musique_player : AudioStreamPlayer = $Musique
@onready var sfx_player : AudioStreamPlayer = $SFXPlayer

func _ready() -> void:
		sfx_player.bus = "SFX"
		musique_player.bus = "Music"

func jouer_sfx(stream: AudioStream, randomise : bool = false) -> void:
	if sfx_player.playing : 
		var  streamer = AudioStreamPlayer.new()
		streamer.stream = stream
		add_child(streamer)
		streamer.finished.connect(streamer.queue_free)
		if randomise :  streamer.pitch_scale = randf_range(0.8, 1.4)
		streamer.play()
		return
	sfx_player.stream = stream
	if randomise : sfx_player.pitch_scale = randf_range(0.8, 1.4)
	sfx_player.play()





func set_volume_musique(value: float) -> void:
	volume_musique = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))

func set_volume_sfx(value: float) -> void:
	volume_sfx = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))


func on_music_finished():
	musique_player.stream 
	musique_player.play()
