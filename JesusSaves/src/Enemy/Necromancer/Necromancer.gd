extends "res://JesusSaves/src/Enemy/Zombie/Zombie.gd"

var fireballRsc = preload("res://JesusSaves/src/Enemy/Projectiles/EnemyFireBall.tscn")

func _ready():
	minDistanceToAttack = 250

func attack():
	.attack()
	var pos = position + Vector2(rand_range(5, -5),rand_range(0, -20)) #a bit of randomness to the vertical position
	if sprite.flip_h:
		pos.x += 20
	else:
		pos.x -= 20
	spawn_something(fireballRsc, pos)
