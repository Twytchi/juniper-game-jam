extends Area2D

@export var waves: Array[WaveData] = []

var current_wave_index := 0
var spawn_points := []
var current_enemies_alive := 0

func _ready():
	body_entered.connect(_on_body_entered)
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

func _on_body_entered(body):
	if current_wave_index >= waves.size() or not body.is_in_group("player"):
		return
	set_deferred("monitoring", false)
	spawn_wave()

func spawn_wave():
	if current_wave_index >= waves.size() : return
	var wave_data = waves[current_wave_index ]
	var spawn_idx = 0
	
	for entry in wave_data.spawns:
		var scene = load(WaveData.ENEMY_PATHS[entry.type])
		
		for i in range(entry.count):
			var enemy = scene.instantiate()
			var marker = spawn_points[spawn_idx % spawn_points.size()]
			
			var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
			enemy.global_position = marker.global_position + offset
			
			if "difficulty" in enemy:
				enemy.difficulty = entry.difficulty
				
			get_parent().call_deferred("add_child", enemy)
			current_enemies_alive += 1
			enemy.tree_exited.connect(_on_enemy_died)
			spawn_idx += 1
			
	current_wave_index += 1

func _on_enemy_died():
	current_enemies_alive -= 1
	if current_enemies_alive <= 0:
		spawn_wave()
	print("123")
