extends Node

const CustomCamera = preload("../Player/Camera2D.gd")
const Player = preload("../Player/Player.gd")

onready var camera2d: CustomCamera = $"/root/MainScene/WorldEnvironment/Player/Camera2D"
onready var player: Player = $"/root/MainScene/WorldEnvironment/Player"

func _ready() -> void:
	# warning-ignore:return_value_discarded
	EventBus.connect("player_damaged", self, "_on_player_damaged")
	# warning-ignore:return_value_discarded
	EventBus.connect("player_attack", self, "_on_player_attack")

func _on_player_damaged(damage: float) -> void:
	if damage > 0:
		camera2d.shake(0.2, 12, 6)

func _on_player_attack():
	if player.has_weapon:
		for body in player.weapon_area2d.get_overlapping_bodies():
			if body.is_in_group(Player.GROUP_ENEMY) and !body.dead:
				camera2d.shake(0.3, 12, 10)
