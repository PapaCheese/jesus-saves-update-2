extends Area2D

const Player = preload("../Player/Player.gd")

var looted: bool = false

func _on_EnergyLoot_body_entered(body) -> void:
	if !looted and body.is_in_group(Player.GROUP_PLAYER):
		looted = true
		body.gain_spell_damage(2)
		$halo.visible = false
		$AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
