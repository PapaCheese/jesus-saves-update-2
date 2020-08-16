extends Area2D

const Player = preload("../Player/Player.gd")

export var skill_number: int = 1

var looted: bool = false

func _on_SkillPrayer_body_entered(body: Node) -> void:
	if !looted and body.is_in_group(Player.GROUP_PLAYER):
		looted = true
		EventBus.emit_signal("player_gain_skill", skill_number)
		$AnimationPlayer.play("looted")
