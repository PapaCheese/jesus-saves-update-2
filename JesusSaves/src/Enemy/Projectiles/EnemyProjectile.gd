extends Area2D

var direction := Vector2(-500, 0)

func start(_pos, _flip):
	position = _pos
	if _flip:
		direction *= -1
	else:
		$AnimatedSprite.flip_h = true

func _ready():
	pass # Replace with function body.

func _process(delta):
	position += direction * delta
