extends Resource
class_name WaveData

enum EnemyType { KAMIKAZE, ARCHER, DASHER, BERSERKER, HEALER, SHEEP, BOSS, HEAL }

const ENEMY_PATHS = {
	EnemyType.KAMIKAZE: "res://Scene/kamikaze_ai.tscn",
	EnemyType.ARCHER:   "res://Scene/archer_ai.tscn",
	EnemyType.DASHER:   "res://Scene/dasher_ai.tscn",
	EnemyType.BERSERKER: "res://Scene/berserker_ai.tscn",
	EnemyType.HEALER:   "res://Scene/healer_ai.tscn",
	EnemyType.SHEEP : "res://Scene/sheep.tscn",
	EnemyType.BOSS :"res://Scene/Boss.tscn",
	EnemyType.HEAL : "res://Scene/healing_item.tscn"
}

@export var spawns: Array[SpawnEntry] = []
