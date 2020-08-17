extends Node

const Player = preload("../Player/Player.gd")

onready var player: Player = $"/root/Game/Levels/Player"
onready var gui_score: Label = $"/root/Game/GUI/Halos"
onready var gui_health: TextureProgress = $"/root/Game/GUI/Health"
onready var gui_energy: TextureProgress = $"/root/Game/GUI/Divinity"

func _ready() -> void:
	# warning-ignore:return_value_discarded
	EventBus.connect("player_gain_skill", self, "_on_player_gain_skill")
	# warning-ignore:return_value_discarded
	EventBus.connect("player_gain_spell_damage", self, "_on_player_gain_spell_damage")
	# warning-ignore:return_value_discarded
	EventBus.connect("player_gain_points", self, "_on_player_gain_points")
	# warning-ignore:return_value_discarded
	EventBus.connect("player_loot_energy", self, "_on_player_loot_energy")

func _on_player_gain_skill(skill_number: int) -> void:
	if player.skills_acquired < 5 and skill_number > player.skills_acquired:
		player.skills_acquired += 1

		match player.skills_acquired:
			1:
				player.selected_skill = player.skills_acquired
				player.gui_spell_lightning.visible = true
#				player.gain_spell_damage(0)
				EventBus.emit_signal("player_gain_spell_damage", 0)
				player.gui_spell_damage.visible = true
			2:
				player.selected_skill = player.skills_acquired
				player.gui_spell_fire.visible = true
#				player.gain_spell_damage(5)
				EventBus.emit_signal("player_gain_spell_damage", 5)
			3:
				player.selected_skill = player.skills_acquired
				player.gui_spell_holy.visible = true
#				player.gain_spell_damage(5)
				EventBus.emit_signal("player_gain_spell_damage", 5)
			4:
				player.selected_skill = player.skills_acquired
				player.gui_spell_ice.visible = true
#				player.gain_spell_damage(5)
				EventBus.emit_signal("player_gain_spell_damage", 5)
			5:
				player.has_lazarus = true
				player.lazarusUsed = false
				player.gui_lazarus.visible = true

#		player.set_selected_skill_ui()
		EventBus.emit_signal("player_select_skill", player.selected_skill)

func _on_player_select_skill(_skill_number: int) -> void:
	for sui in player.gui_spells.size():
		if sui + 1 == player.selected_skill:
			player.gui_spells[sui].get_node("Frame").visible = true
		else:
			player.gui_spells[sui].get_node("Frame").visible = false

func _on_player_gain_spell_damage(points: int) -> void:
	player.sfx_pickup.play()

	if player.spell_damage < player.max_spell_damage:
		player.spell_damage += points

	player.gui_spell_damage.text = "Spell Damage: " + str(player.spell_damage)

func _on_player_gain_points(points: int) -> void:
	player.score += points
	gui_score.gain_points(player.score)

func _on_player_loot_energy() -> void:
	if player.energy < player.max_energy:
		if player.energy + 3 <= player.max_energy:
			player.energy += 3
		else:
			player.energy = player.max_energy
		gui_energy.value = player.energy
		print("energy=", gui_energy.value)

	if player.health < player.max_health:
		if player.health < player.max_health:
			player.health += 1
		else:
			player.health = player.max_health
		gui_health.value = player.health

	player.sfx_pickup.play()
	EventBus.emit_signal("player_gain_points", 10)
