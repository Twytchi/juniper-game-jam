extends CharacterBody2D
class_name EnemyBase

@onready var player = get_tree().get_first_node_in_group("player")
@onready var hurtbox: Area2D = $Hurtbox
@onready var spin_component: SpinComponent = $SpinComponent
@onready var sprite : Node2D=  $Sprite2D

@export var detection_range: float = 500.0
@export var speed: float = 80.0
@export var max_health: int = 30

var current_health: float


var height := 500.0

var is_invincible := false
var iframe_duration := 0.0

var is_dead := false
@onready var shadow: Node2D = $Node2D

var knockback_velocity := Vector2.ZERO
var knockback_friction := 800.0
const GRAVITY := 900
var vertical_velocity := 0.0

signal on_death

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

func _process(_delta: float) -> void:
	sprite.position.y = -height
	if hurtbox : hurtbox.position.y = -height
	var shadow_scale = clamp(1.0 - (height / 200.0), 0.5, 1.0)
	if shadow : shadow.scale = Vector2(shadow_scale, shadow_scale)

func _physics_process(delta):
	if knockback_velocity.length() > 1.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	else:
		match state:
			State.IDLE:
				idle()
			State.CHASE:
				chase_player()
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
		if state == State.HIT :
			state = State.IDLE
	move_and_slide()


func idle():
	velocity = Vector2.ZERO
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= detection_range:
		state = State.CHASE


func chase_player():
	if player == null:
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed


func attack():
	pass

func recover():
	pass


func _on_hurtbox_area_entered(area):
	if area is PlayerHitbox :
		area = area as PlayerHitbox
		apply_damage(area.get_damage(), area)


func apply_damage(attaq: AttackData, source: Node2D  = null):
	if is_invincible or state == State.DEAD:
		return
	if not attaq : return
	current_health -= attaq.damage

	if source:
		var direction = (global_position - source.global_position).normalized()

		knockback_velocity = direction * attaq.knockback
	if attaq.animation_name == &"Luncher":
		vertical_velocity = 500
	if spin_component :
		spin_component.add_charge(attaq.spin_power)
	hit_flash()
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



func hit_flash():
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		sprite.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)


func die():
	state = State.DEAD
	on_death.emit()
	queue_free()
