extends Control

@onready var rank_label: Label = $VBoxContainer/rank
@onready var multiplier_label: Label = $VBoxContainer/mult
@onready var score_label: Label = $VBoxContainer/score

var current_score: int = 0
var current_multiplier: float = 1.0

func _ready():
	ScoreManager.score_updated.connect(_on_score_updated)
	_update_ui(0, 1.0)

func _on_score_updated(new_score: int, new_multiplier: float):
	if new_score != current_score:
		_animate_pop(score_label)
		
	if new_multiplier != current_multiplier:
		_animate_pop(rank_label)
		_animate_pop(multiplier_label)
		
	current_score = new_score
	current_multiplier = new_multiplier
	_update_ui(new_score, new_multiplier)

func _update_ui(new_score: int, new_multiplier: float):
	score_label.text = "%08d" % new_score
	multiplier_label.text = "x" + String.num(new_multiplier, 1)
	
	rank_label.text = _get_rank_string(new_multiplier)
	rank_label.modulate = _get_rank_color(new_multiplier)

func _get_rank_string(mult: float) -> String:
	if mult >= 40.0: return "SSS"
	if mult >= 25.0: return "SS"
	if mult >= 15.0 : return "S"
	if mult >= 5.0: return "A"
	if mult >= 2.0 : return "B"
	if mult >= 1.3: return "C"
	return "D"

func _get_rank_color(mult: float) -> Color:
	if mult >= 15.0: return Color.GOLD
	if mult >= 5.0: return Color.ORANGE_RED
	if mult >= 2.0: return Color.MEDIUM_PURPLE
	if mult >= 1.3: return Color.DEEP_SKY_BLUE
	return Color.WHITE

func _animate_pop(node: Control):
	node.pivot_offset = node.size / 2
	
	var tween = create_tween()
	node.scale = Vector2(1.5, 1.5)
	tween.tween_property(node, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
