extends Node

const Player = preload("../Player/Player.gd")

onready var player: Player = $"/root/Game/Levels/Player"

func _physics_process(delta: float) -> void:
	if !player:
		return
	# ANIMATION
	EventBus.emit_signal("player_animation", Player.PlayerAnimation.IDLE)

	if player.is_on_floor():
		if player.linear_velocity.x < -Player.SIDING_CHANGE_SPEED:
			EventBus.emit_signal("player_change_facing", Player.DirectionFacing.LEFT)
			EventBus.emit_signal("player_animation", Player.PlayerAnimation.WALK)

		if player.linear_velocity.x > Player.SIDING_CHANGE_SPEED:
			EventBus.emit_signal("player_change_facing", Player.DirectionFacing.RIGHT)
			EventBus.emit_signal("player_animation", Player.PlayerAnimation.WALK)
	else:
		if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
			EventBus.emit_signal("player_change_facing", Player.DirectionFacing.LEFT)

		if Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
			EventBus.emit_signal("player_change_facing", Player.DirectionFacing.RIGHT)

		if player.linear_velocity.y < 0:
			EventBus.emit_signal("player_animation", Player.PlayerAnimation.HOVER)
		else:
			EventBus.emit_signal("player_animation", Player.PlayerAnimation.FALL)
