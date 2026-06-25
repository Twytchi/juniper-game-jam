extends Resource
class_name WaveData

enum EnemyType { KAMIKAZE, ARCHER, DASHER, BERSERKER, HEALER, SHEEP }

const ENEMY_PATHS = {
	EnemyType.KAMIKAZE: "res://Scene/kamikaze_ai.tscn",
	EnemyType.ARCHER:   "res://Scene/archer_ai.tscn",
	EnemyType.DASHER:   "res://Scene/dasher_ai.tscn",
	EnemyType.BERSERKER: "res://Scene/berserker_ai.tscn",
	EnemyType.HEALER:   "res://Scene/healer_ai.tscn",
	EnemyType.SHEEP : "res://Scene/sheep.tscn"
}

@export var spawns: Array[SpawnEntry] = []
