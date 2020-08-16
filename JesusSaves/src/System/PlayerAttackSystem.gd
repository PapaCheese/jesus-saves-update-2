extends Node

const Player = preload("../Player/Player.gd")
const LightningSpell = preload("../Spell/LightningSpell.tscn")
const FireSpell = preload("../Spell/FireSpell.tscn")
const Weapon = preload("../Weapon/CrossLoot.gd")

onready var player: Player = $"/root/Game/Levels/Player"
onready var gui_damage: Label = $"/root/Game/GUI/Damage"

func _ready() -> void:
	# warning-ignore:return_value_discarded
	EventBus.connect("player_get_weapon", self, "_on_player_get_weapon")
	# warning-ignore:return_value_discarded
	EventBus.connect("player_attack", self, "_on_player_attack")

func _physics_process(_delta: float) -> void:
	if player and !player.can_attack:
		return

	if Input.is_action_just_pressed(InputSystem.PLAYER_LIGHT_ATTACK_1):
		_light_attack_1()
	elif Input.is_action_pressed(InputSystem.PLAYER_MAGIC_ATTACK_1):
		_magic_attack_1()

func _input(event) -> void:
	if !player:
		return
	if player.skills_acquired <= 1:
		return

	# Handle weapon_up selection action
	if Input.is_action_just_pressed(InputSystem.PLAYER_WEAPON_UP):
		_weapon_up()

	# Handle weapon_down selection action
	if Input.is_action_just_pressed(InputSystem.PLAYER_WEAPON_DOWN):
		_weapon_down()

	# Handle specific keyboard selection
	if event is InputEventKey and event.pressed:
		_select_skill(event.scancode)

func _light_attack_1() -> void:
	if !player or !player.has_weapon:
		return

	if player.weapon_animation_player.current_animation == "light_attack_1":
		player.weapon_animation_player.play("light_attack_2")
	else:
		player.weapon_animation_player.play("light_attack_1")

	player.hover()
	player.can_attack = false

func _magic_attack_1() -> void:
	if !player or player.energy <= player.spell_cost and player.skills_acquired <= 0:
		return

	player.skill_timer.start()
	player.spell_hit()

	var spell

	match player.selected_skill:
		1:
			spell = LightningSpell.instance()
		2:
			spell = FireSpell.instance()
		3:
			player.spell_holy.emitting = true
		4:
			player.spell_ice.emitting = true
		5:
			pass

	if spell:
		spell.position = player.spells.global_position
		player.get_parent().add_child(spell)

	player.energy -= player.spell_cost
	player.gui_energy.value = player.energy

	player.hover()

	player.can_attack = false
	player.sfx_lightning.play()

func _weapon_up() -> void:
	if player.selected_skill < player.skills_acquired:
		player.selected_skill += 1
	else:
		player.selected_skill = 1

func _weapon_down() -> void:
	if player.selected_skill > 1:
		player.selected_skill -= 1
	else:
		player.selected_skill = player.skills_acquired

func _select_skill(scancode: int) -> void:
	match scancode:
		KEY_1:
			player.selected_skill = 1
		KEY_2:
			if player.skills_acquired > 1:
				player.selected_skill = 2
		KEY_3:
			if player.skills_acquired > 2:
				player.selected_skill = 3
		KEY_4:
			if player.skills_acquired > 3:
				player.selected_skill = 4

	EventBus.emit_signal("player_select_skill", player.selected_skill)

func _on_player_get_weapon(weapon: Weapon) -> void:
	if !player.has_weapon:
		player.has_weapon = true
		gui_damage.visible = true

	if weapon.damage > player.damage:
		player.weapon_sprite.texture = weapon.sprite.texture
		player.damage = weapon.damage

	gui_damage.text = "Damage: " + str(player.damage)
	player.sfx_pickup.play()
	EventBus.emit_signal("player_gain_points", 100)

func _on_player_attack():
	if player.has_weapon:
		for body in player.weapon_area2d.get_overlapping_bodies():
			if body.is_in_group(Player.GROUP_ENEMY) and !body.dead:
				body.get_hit(player, player.damage)
				EventBus.emit_signal("enemy_damaged", body, player.damage)
				player.sfx_slash.play()

				# This would get called multiple times if player hit multiple enemies
				# Moved to CameraSystem
#				camera2d.shake(0.3, 12, 10)
