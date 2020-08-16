extends Label

onready var animation_player = $AnimationPlayer

func gain_points(score: int) -> void:
	text = str(score)
	animation_player.play("gain")
