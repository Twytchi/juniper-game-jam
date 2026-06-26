extends Area2D

var is_pick := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if is_pick : return
	
	if body is Player :
		is_pick = true
		body.health += 25
		if body.health > 100 :
			body.health = 100
		queue_free()
