extends KinematicBody2D

const GRAVITY_VEC: Vector2 = Vector2(0, 1200)
const MAX_FALL_SPEED: float  = 500.0
const FLOOR_NORMAL: Vector2 = Vector2(0, -1)
const SLOPE_SLIDE_STOP: float = 25.0
const WALK_SPEED: float = 75.0 # pixels/sec

export(float) var damage: float = 5.0
export(bool) var debug: bool = false

#export(Array) var components: Array = [
#	{"health": 100.0}
#]
#export(Dictionary) var components: Dictionary = {
#	"health": 100.1,
#	"linear_velocity": Vector2()
#}

var health: float = 100.0
var linear_velocity: Vector2 = Vector2()
var facing_left: bool = true
var can_attack: bool = true
var dead: bool = false
var knocked_back: bool = false
var target
var state_machine: StateMachine = StateMachine.new()

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var left_attack_area: Area2D = $LeftAttackArea
onready var right_attack_area: Area2D = $RightAttackArea
onready var attack_timer: Timer = $AttackTimer
onready var hp_bar: ProgressBar = $HpBar
onready var floor_area: Area2D = $FloorArea

func _get_property_list() -> Array:
	return []

func _ready() -> void:
	if is_in_group("Boss"):
		health += 700

	hp_bar.max_value = health
	hp_bar.value = health

	state_machine.target = self
	state_machine.default_state = state_machine.state_create(ZombieStates.IdleState)

func _process(delta: float) -> void:
	state_machine._process(delta)

	if !dead and target and animation_player.current_animation != "hit" and animation_player.current_animation != "attack" and !knocked_back:
		var dis = global_position - target.global_position

		if dis.x < 50 and dis.x > -50 and can_attack:
			play_attack_anim(target)
		else:
			var spd = -dis.normalized().x

			if spd > 0:
				face_left(false)
			elif spd < 0:
				face_left(true)
			linear_velocity.x = spd * WALK_SPEED
			if spd > 0.2 or spd < -0.2:
				animation_player.play("walk")
			else:
				animation_player.play("idle")

	### MOVEMENT ###
	# Apply gravity
	if !dead and linear_velocity.y < MAX_FALL_SPEED:
		linear_velocity += delta * GRAVITY_VEC

	if knocked_back:
		if linear_velocity.x > 0:
			linear_velocity.x -= delta * 500

			if linear_velocity.x <= 0:
				linear_velocity.x = 0
				knocked_back = false
		else:
			linear_velocity.x += delta * 500
			if linear_velocity.x >= 0:
				linear_velocity.x = 0
				knocked_back = false

	# Move and slide
	linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
#	var on_floor = is_on_floor()

func _on_WalkTimer_timeout():
	if !dead and !target:
		if animation_player.current_animation != "attack" and animation_player.current_animation != "hit":
			var rnd = rand_range(1,-1)
			if rnd < 0.5 and rnd > -0.5:
				rnd =0
				animation_player.play("idle")
			else:
				animation_player.play("walk")
			linear_velocity.x = rnd * WALK_SPEED
			if rnd > 0:
				face_left(false)
			elif rnd < 0:
				face_left(true)

func _on_LeftAttackArea_body_entered(body) -> void:
	if !dead:
#		face_left(true)
		play_attack_anim(body)

func _on_RightAttackArea_body_entered(body) -> void:
	if !dead:
#		face_left(false)
		play_attack_anim(body)

func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	if anim_name == "hit" and dead:
		animation_player.play("die")

func _on_AttackTimer_timeout() -> void:
	can_attack = true

func _on_FloorArea_body_exited(body) -> void:
	linear_velocity.x *= -1
	face_left(!facing_left)
#	$FloorArea.position.x /= -1

func say(message: String) -> void:
	print("Zombie (", get_instance_id(), ") says: ", message)

func distance_from_player(target: Node2D) -> float:
	"""
	Returns the distance to the players position
	"""
	return position.distance_to(target.position)

func should_patrol() -> bool:
	return false

func get_hit(body, _damage):
	if !dead:
		if !target:
			target = body
		health -= _damage
		if health <= 0:
			die()
		animation_player.play("hit")
		knock_back()
		hp_bar.value = health

func knock_back():
	knocked_back = true
	if target.global_position.x > global_position.x:
		linear_velocity.x = -220
	else:
		linear_velocity.x = 220

func die():
	if !dead:
		dead = true
		animation_player.play("die")
		linear_velocity.x = 0
		collision_mask = 32
		EventBus.emit_signal("player_gain_points", 50)
		if is_in_group("Boss") and get_parent().get_parent().has_method("spawn_crate"):
			get_parent().get_parent().spawn_crate()
			target.gain_points(250)

func face_left(boo: bool):
	sprite.flip_h = !boo
	facing_left = boo
	if boo:
		$FloorArea.position.x = -30
	else:
		$FloorArea.position.x = 30

func attack():
	var area: Area2D
	if facing_left:
		area = left_attack_area
	else:
		area = right_attack_area
#	target.get_hit(damage)
	for a in area.get_overlapping_bodies():
		if a.is_in_group("Player"):
			a.get_hit(damage)

func play_attack_anim(body):
	if !dead and animation_player.current_animation != "hit":
		if body.is_in_group("Player"):
			if !target:
				target = body
			if animation_player.current_animation != "hit":
				animation_player.play("attack")
				can_attack = false
				attack_timer.start()
			linear_velocity.x = 0
		else:
			linear_velocity.x *= -1
			face_left(!facing_left)

class HealthComponent extends Resource:
	var health: float = 100.0
	var linear_velocity := Vector2()
