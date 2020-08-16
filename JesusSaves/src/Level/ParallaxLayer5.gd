extends ParallaxLayer

const SPEED = 10

func _process(delta: float) -> void:
	motion_offset.x -= delta * SPEED
