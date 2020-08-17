extends KinematicBody2D

# TODO: a Player doesn't really has-a Camera2D
# Refactor this out to a signal and system to decouple (CameraSystem?)
const CustomCamera = preload("./Camera2D.gd")

enum DirectionFacing {
	LEFT,
	RIGHT
}

enum PlayerAnimation {
	WALK,
	HOVER,
	FALL,
	IDLE
}

const GROUP_ENEMY: String = "Enemy"
const GROUP_PLAYER: String = "Player"
const GRAVITY_VEC: Vector2 = Vector2(0, 500) # orig=0,1000
const MAX_FALL_SPEED: float = 250.0 # (orig=500.0)
const FLOOR_NORMAL: Vector2 = Vector2(0, -1)
const SLOPE_SLIDE_STOP: float = 25.0
const WALK_SPEED: float = 140.0 # pixels/sec (orig=180.0)
const JUMP_SPEED: float = 400.0 # (orig=550.0)
const SIDING_CHANGE_SPEED: float = 70.0
const LERP_SPEED: float = 0.2

const ANIMATIONS = {
	PlayerAnimation.WALK: "walk",
	PlayerAnimation.HOVER: "hover",
	PlayerAnimation.FALL: "fall",
	PlayerAnimation.IDLE: "idle"
}

# TODO: many of these are not properties of a Player
# and should be moved to their respective data structures (weapon, spell, skill)
var last_checkpoint: Vector2 = Vector2()
var score: int = 0
var max_health: float = 100.0
var max_energy: float = 100.0
var max_spell_damage: float = 200.0
var health: float = 100.0
var energy: float = 100.0
var damage: float = 10.0
var spell_damage: float = 10.0
var spell_cost: int = 5
var linear_velocity: Vector2 = Vector2.ZERO
var anim: String = ""
var weaponAnim: String = ""
var can_attack: bool = true
var should_hover: bool = false
var has_weapon: bool = false
var has_lazarus: bool = false
var lazarusUsed: bool = false
var skills_acquired: int = 0
var selected_skill: int = 0
var fall_limit: float = 3000.0
var level: int = 1

onready var gui_spell_lightning: TextureRect = $"/root/Game/GUI/LightningSpell"
onready var gui_spell_fire: TextureRect = $"/root/Game/GUI/FireSpell"
onready var gui_spell_holy: TextureRect = $"/root/Game/GUI/HolySpell"
onready var gui_spell_ice: TextureRect = $"/root/Game/GUI/IceSpell"
onready var gui_lazarus: Sprite = $"/root/Game/GUI/Lazarus"
onready var gui_health: TextureProgress = $"/root/Game/GUI/Health"
onready var gui_energy: TextureProgress = $"/root/Game/GUI/Divinity"
onready var gui_damage: Label = $"/root/Game/GUI/Damage"
onready var gui_spell_damage: Label = $"/root/Game/GUI/SpellDamage"
onready var gui_score: Label = $"/root/Game/GUI/Halos"

onready var camera2d: CustomCamera = $Camera2D
onready var sprite: Sprite = $Sprite
onready var spells: Node2D = $Spells
onready var tween: Tween = $Tween
onready var skill_timer: Timer = $SkillTimer
onready var weapon_area2d: Area2D = $Sprite/WeaponArea
onready var weapon_sprite: Sprite = $Sprite/Weapon
onready var spell_area2d: Area2D = $Spells/AreaOfEffect
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var weapon_animation_player: AnimationPlayer = $Sprite/WeaponAnimationPlayer
onready var spell_holy: Particles2D = $Spells/HolySpell
onready var spell_ice: Particles2D = $Spells/IceSpell
onready var sfx_slash: AudioStreamPlayer2D = $Slash
onready var sfx_lightning: AudioStreamPlayer2D = $Lightning
onready var sfx_footstep: AudioStreamPlayer2D = $FootStep
onready var sfx_pickup: AudioStreamPlayer2D = $PickUp
onready var gui_spells: Array = [gui_spell_lightning, gui_spell_fire, gui_spell_holy, gui_spell_ice]

func _ready() -> void:
	EventBus.connect("player_animation", self, "_on_player_animation")

	gui_health.max_value = health
	gui_health.value = health
	gui_energy.max_value = energy
	gui_energy.value = energy
#	if !last_checkpoint:
#		last_checkpoint = global_position

	set_process(false)
	set_physics_process(false)
	PlayerMovementSystem.set_physics_process(false)
#	PlayerAbilitySystem.player = self
#	PlayerAttackSystem.player = self
#	PlayerAnimationSystem.player = self

func start():
	set_process(true)
	set_physics_process(true)
	PlayerMovementSystem.set_physics_process(true)

func _physics_process(delta: float) -> void:
	if !should_hover:
		animation_player.play(anim)
		if anim == ANIMATIONS[PlayerAnimation.WALK] and !sfx_footstep.playing:
			sfx_footstep.playing = true
		elif anim != ANIMATIONS[PlayerAnimation.WALK] and sfx_footstep.playing:
			sfx_footstep.stop()

"""
Listens for event to change the player animation using enum
"""
func _on_player_animation(animation) -> void:
	anim = ANIMATIONS[animation]

func get_hit(_damage):
	health -= _damage

	if health <= 0:
		if has_lazarus and !lazarusUsed:
			lazarusUsed = true
			gui_lazarus.visible = false
		else:
			EventBus.emit_signal("player_respawn")
			lazarusUsed = false
			gui_lazarus.visible = true

		# Should this be handled by player_respawn signal handler?
		# Probably should be a player_health_update signal?
		health = 100

	gui_health.value = health

func _on_Tween_tween_all_completed() -> void:
	if sprite.offset.y == 0:
		should_hover = false

func _on_skill_timer_timeout() -> void:
	stop_hovering()

	if spell_holy.emitting:
		spell_holy.emitting = false
	elif spell_ice.emitting:
		spell_ice.emitting = false

	can_attack = true

# TODO: rename to attack or light_attack_1?
func hit() -> void:
	EventBus.emit_signal("player_attack")

func spell_hit() -> void:
	for body in spell_area2d.get_overlapping_bodies():
		if body.is_in_group(GROUP_ENEMY):
			damage += 15
			body.get_hit(self, spell_damage)
			damage -= 15

func hover() -> void:
	should_hover = true
	animation_player.play(ANIMATIONS[PlayerAnimation.HOVER])
	tween.interpolate_property(
		sprite,
		"offset:y",
		sprite.offset.y,
		-8,
		1,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)
	tween.start()

func stop_hovering() -> void:
	can_attack = true
	tween.interpolate_property(
		sprite,
		"offset:y",
		sprite.offset.y,
		0,
		1,
		Tween.TRANS_QUINT,
		Tween.EASE_IN
	)
	tween.start()

# TODO: this belongs to camera, not really player? Maybe fall limit does?
func set_limits(left, right, fall) -> void:
	camera2d.limit_left = left
	camera2d.limit_right = right
	fall_limit = fall
