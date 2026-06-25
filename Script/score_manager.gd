extends Node

signal score_updated(current_score, current_multiplier)

var score: int = 0
var multiplier: float = 1.0

var action_history: Array[String] = []
const HISTORY_LIMIT: int = 10

var action_data = {
	"light_strike1": {"points": 10, "mult_add": 0.1, "reset_mult": false},
	"light_strike2": {"points": 10, "mult_add": 0.1, "reset_mult": false},
	"heavy_strike": {"points": 8, "mult_add": 0.1, "reset_mult": false},
	"luncher": {"points": 15, "mult_add": 0.1, "reset_mult": false},
	"dive": {"points": 8, "mult_add": 0.1, "reset_mult": false},
	"spin": {"points": 25, "mult_add": 0.05, "reset_mult": false},
	"missile": {"points": 30, "mult_add": 0.2, "reset_mult": false},
	"get_hit": {"points": -20, "mult_add": -0.2, "reset_mult": false}
}



func player_did_light_strike(a : String = "1"):
	_process_action("light_strike" + a)

func player_luncher():
	_process_action("luncher")

func player_spin():
	_process_action("spin")

func player_dive():
	_process_action("dive")

func player_missile():
	_process_action("missile")

func player_did_heavy_strike():
	_process_action("heavy_strike")

func player_get_hit():
	_process_action("get_hit")

func _process_action(action_name: String):
	if not action_data.has(action_name):
		push_warning("Action non reconnue dans le ScoreManager: ", action_name)
		return
		
	var data = action_data[action_name]
	
	var spam_modifier = _calculate_spam_modifier(action_name)
	
	if data.get("reset_mult", false):
		multiplier = 1.0
	
	var points_gained = int(data["points"] * multiplier * spam_modifier)
	score = max(0, score + points_gained)
	
	if spam_modifier > 0:
		multiplier += data.get("mult_add", 0.0)
		
	_update_history(action_name)
	
	score_updated.emit(score, multiplier)

func _calculate_spam_modifier(action_name: String) -> float:
	if action_data[action_name]["points"] < 0:
		return 1.0
		
	var count = 0
	for past_action in action_history:
		if past_action == action_name:
			count += 1
			
			
	if action_name == "missile" :
		return 1.0
	if count <= 2:
		return 1.0
	elif count <= 4:
		return 0.5
	else:
		return 0.0

func _update_history(action_name: String):
	action_history.push_front(action_name)
	
	if action_history.size() > HISTORY_LIMIT:
		action_history.pop_back()
