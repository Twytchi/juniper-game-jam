extends CharacterBody2D
class_name EnemyBase

@onready var player = get_tree().get_first_node_in_group("player")
@onready var hurtbox: Area2D = $Hurtbox
@onready var spin_component: SpinComponent = $SpinComponent
@onready var sprite : Node2D=  $Sprite2D
@export var  separation_area : Area2D

@export var detection_range: float = 500.0
@export var speed: float = 80.0
@export var max_health: int = 30

var difficulty_multiplier : float = 1.0

var current_health: float

var s_base_pos : Vector2

var height := 500.0

var hit_sfx :Array[AudioStream]= [
	preload("res://Asset/sfx/sound_hit1.wav"),
	preload("res://Asset/sfx/Boom30.wav"),
	preload("res://Asset/sfx/hitt/tm2_slash000.wav"),
	preload("res://Asset/sfx/hitt/tm2_hit004.wav"),
	preload("res://Asset/sfx/hitt/tm2_hit005.wav")
	
	
]

var metal_hit : Array[AudioStream]= [
	preload("res://Asset/sfx/metal-online-audio-converter.mp3"),
	preload("res://Asset/sfx/metal04gr-converted.mp3"),
]

var thump_sfx : Array[AudioStream]= [
	preload("res://Asset/sfx/louder-thump.mp3"),
	preload("res://Asset/sfx/380643__jameswrowles__thump-5.wav")
	
]


var is_invincible := false
@export var iframe_duration := 0.0

var is_dead := false
@onready var shadow: Node2D = $Node2D

var knockback_velocity := Vector2.ZERO
var knockback_friction := 800.0
const GRAVITY := 900
var vertical_velocity := 0.0

signal height_reached_zero
signal on_death

var game_camera : CameraGame

enum State {
	IDLE,
	CHASE,
	ATTACK,
	RECOVER,
	HIT,
	DEAD
}

var state = State.IDLE


func _ready():
	current_health = max_health
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	if sprite.get_child(0) : 
		s_base_pos = sprite.get_child(0).position
	
	scale  = scale * difficulty_multiplier

func _process(_delta: float) -> void:
	sprite.position.y = -height
	if hurtbox : hurtbox.position.y = -height
	var shadow_scale = clamp(1.0 - (height / 200.0), 0.5, 1.0)
	if shadow : shadow.scale = Vector2(shadow_scale, shadow_scale)
	if height > 0 :
		sprite.rotation += 10 * _delta 
	else :
		sprite.rotation = 0 
func _physics_process(delta):
	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	else:
		match state:
			State.IDLE:
				idle()
			State.CHASE:
				chase_player(delta)
			State.ATTACK:
				attack()
			State.RECOVER:
				recover()
			State.HIT:
				pass
			State.DEAD:
				velocity = Vector2.ZERO
	
	vertical_velocity -= GRAVITY * delta * (1.0 if (vertical_velocity > 0  )else 1.6)
	height += vertical_velocity * delta
	
	if height > 0 :
		state = State.HIT
		
	
	if height <= 0.0:
		height = 0.0
		height_reached_zero.emit()
		if state == State.HIT :
			state = State.IDLE
	move_and_slide()


func idle():
	velocity = Vector2.ZERO
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= detection_range:
		state = State.CHASE


func chase_player(delta : float):
	if player == null:
		return
	var direction = (player.global_position - global_position).normalized()
	if not separation_area : 
		return
	var separation_vector = calculate_separation_vector()
	var final_direction = (direction + separation_vector * 100.0 * delta).normalized()
	var target_velocity = final_direction * speed
	velocity = velocity.lerp(target_velocity, 15* delta)


func calculate_separation_vector() -> Vector2:
	
	var separation = Vector2.ZERO
	var neighbors = separation_area.get_overlapping_bodies()
	
	for neighbor in neighbors:
		if neighbor == self:
			continue
			

		var diff = global_position - neighbor.global_position

		var distance = diff.length()
		
		if distance > 0:
			separation += diff.normalized() / distance 
			
	return separation.normalized()


func attack():
	pass

func recover():
	velocity = Vector2.ZERO
	


func _on_hurtbox_area_entered(area):
	if area is PlayerHitbox :
		area = area as PlayerHitbox
		apply_damage(area.get_damage(), area)


func apply_damage(attaq: AttackData, source: Node2D  = null):
	if is_invincible or state == State.DEAD:
		return
	if not attaq : return
	current_health -= attaq.damage
	print(2466)
	if get_node_or_null("hit_particle") : 
		$hit_particle.emitting = true

	if source:
		var direction = (global_position - source.global_position).normalized()

		knockback_velocity = direction * attaq.knockback
	if attaq.animation_name == &"Luncher":
		vertical_velocity = 500
		ScoreManager.player_luncher()
	if attaq.animation_name in [&"Slash1", &"Slash3"] :
		ScoreManager.player_did_light_strike()
	if attaq.animation_name in [&"Slash2", &"Thrust"] :
		ScoreManager.player_did_light_strike("2")
	if attaq.animation_name == &"Heavy1":
		ScoreManager.player_did_heavy_strike()
	if attaq.animation_name == &"Dive" :
		ScoreManager.player_dive()
	if attaq.animation_name == &"Spin" :
		ScoreManager.player_spin()
	if spin_component :
		spin_component.add_charge(attaq.spin_power)
	hit_flash()
	shake_sprite()
	game_camera = get_tree().get_first_node_in_group("camera")
	if game_camera :
		game_camera.hit_shake(randf_range(4.0, 7.0), 20.0) 
	start_iframes()

	if current_health <= 0:
		die()
	else:
		state = State.HIT


func start_iframes():
	is_invincible = true
	await get_tree().create_timer(iframe_duration).timeout
	is_invincible = false
	if state == State.HIT:
		state = State.CHASE


func shake_sprite(duration: float = 0.4, intensity: float = 12.0, shakes: int = 8):
	var sprite_t = sprite.get_child(0)
	if not sprite_t : return
	sprite_t.position = s_base_pos
	var tween = create_tween()
	var time_per_shake = duration / float(shakes)
	
	for i in range(shakes):
		var current_intensity = intensity * (1.0 - float(i) / float(shakes))
		var random_offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		tween.tween_property(sprite_t, "position", s_base_pos+ random_offset, time_per_shake)
	tween.tween_property(sprite_t, "position", s_base_pos, time_per_shake)


func hit_flash():
	SoundManager.jouer_sfx(hit_sfx[randi_range(0, 4)], true)
	SoundManager.jouer_sfx(metal_hit[randi_range(0, 1)])
	SoundManager.jouer_sfx(thump_sfx[randi_range(0, 1)])
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		
		if randf() > 0.5 :
			sprite.modulate = Color(1, 0.3, 0.3)
		else : 
			sprite.modulate = Color(0.872, 0.465, 0.0, 1.0)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)


func die():
	state = State.DEAD
	on_death.emit()
	queue_free()


func check_if_inside_wall() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = $CollisionShape2D.shape
	query.transform = global_transform 
	query.collision_mask = 3
	var results = space_state.intersect_shape(query)
	return results.size() > 0
