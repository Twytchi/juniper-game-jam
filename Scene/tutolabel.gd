extends RichTextLabel

@export var spawn_zone : SpawnZone
@export var typing_speed : float = 0.01

var current_text = 0

var text_array : Array[String] = [ 
	"[wave amp=30 freq=5]An Unknown menace ![/wave] Use [color=yellow][b]J[/b][/color] for light attack and [color=orange][b]K[/b][/color] for heavy attacks... Kill them !",
	"[shake rate=20 level=10][color=green]Nice ![/color][/shake] More of them are coming! Don't take any chances... use [color=cyan][b]Space[/b][/color] to avoid attacks.",
	"When an enemy starts flashing, hold [color=magenta][b]L[/b][/color] or [color=magenta][b]I[/b][/color] to [b]grab them[/b] and turn them into a [wave amp=20 freq=8]spinning missile[/wave] !",
	"[b]Nice ! Have fun now ![/b]",
	"[wave amp=50 freq=3][color=gold]You're ready to accomplish your mission.[/color][/wave]"
]

var tween : Tween

func _ready() -> void:
	bbcode_enabled = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	if spawn_zone: 
		spawn_zone.next_wave.connect(change_text)
	change_text()

func change_text() -> void:
	if current_text >= text_array.size():
		return
		
	if tween:
		tween.kill()
	
	text = text_array[current_text]
	current_text += 1
	
	visible_ratio = 0.0
	modulate.a = 0.0
	
	pivot_offset = size / 2
	scale = Vector2(0.7, 0.7)
	
	tween = create_tween()
	
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
		
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.15)
	
	var duration = text.length() * typing_speed
	tween.parallel().tween_property(self, "visible_ratio", 1.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)
