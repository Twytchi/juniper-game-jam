extends Camera2D
class_name CameraGame

var shake_intensity: float = 0.0
var shake_fade: float = 5.0
var noise := FastNoiseLite.new()
var noise_y: float = 0.0

@onready var default_zoom: Vector2 = zoom

func _ready() -> void:
	randomize()
	noise.seed = randi()
	noise.frequency = 0.5

func _process(delta: float) -> void:
	if shake_intensity > 0:
		shake_intensity = move_toward(shake_intensity, 0.0, shake_fade * delta)
		noise_y += delta * 100.0
		offset.x = noise.get_noise_2d(noise_y, 0) * shake_intensity
		offset.y = noise.get_noise_2d(0, noise_y) * shake_intensity
	else:
		offset = Vector2.ZERO

func hit_shake(intensity: float = 15.0, fade: float = 40.0) -> void:
	shake_intensity = intensity
	shake_fade = fade

func hit_stop(duration: float = 0.1, time_scale: float = 0.05) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale, true, false, true).timeout
	Engine.time_scale = 1.0

func zoom_to_node(target_node: Node2D, zoom_factor: float = 1.5, duration: float = 0.2) -> void:
	var tween = create_tween().set_parallel(true)
	
	var target_zoom = default_zoom * zoom_factor
	tween.tween_property(self, "zoom", target_zoom, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	if target_node:
		var global_pos = target_node.global_position
		tween.tween_property(self, "global_position", global_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func reset_zoom(duration: float = 0.2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "zoom", default_zoom, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
