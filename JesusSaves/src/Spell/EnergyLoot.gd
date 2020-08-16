extends Area2D

var looted: bool = false

onready var halo: Sprite = $halo
onready var animated_sprite: AnimatedSprite = $AnimatedSprite

func _on_EnergyLoot_body_entered(body) -> void:
	if !looted and body.is_in_group("Player"):
		looted = true
		halo.visible = false
		animated_sprite.play()
		EventBus.emit_signal("player_loot_energy")

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
