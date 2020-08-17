extends Node

const Player: Script = preload("../Player/Player.gd")

const TARGET_SPEED_MODIFIER: float = 1.0

onready var player: Player = $"/root/Game/Levels/Player"

func _ready() -> void:
	# warning-ignore:return_value_discarded
	EventBus.connect("player_respawn", self, "_on_player_respawn")
	# warning-ignore:return_value_discarded
	EventBus.connect("player_change_facing", self, "_on_player_change_facing")

func _physics_process(delta: float) -> void:
	if !player:
		return
	# MOVEMENT
	if player.linear_velocity.y < Player.MAX_FALL_SPEED:
		player.linear_velocity += delta * Player.GRAVITY_VEC

	if player.position.y > player.fall_limit:
		EventBus.emit_signal("player_respawn")

	player.linear_velocity = player.move_and_slide(player.linear_velocity, Player.FLOOR_NORMAL, Player.SLOPE_SLIDE_STOP)

	var on_floor = player.is_on_floor()

	# CONTROL
	var target_speed = 0.0

	if Input.is_action_pressed(InputSystem.PLAYER_MOVE_LEFT):
		target_speed -= TARGET_SPEED_MODIFIER

	if Input.is_action_pressed(InputSystem.PLAYER_MOVE_RIGHT):
		target_speed += TARGET_SPEED_MODIFIER

	target_speed *= Player.WALK_SPEED

	# slippery amount
	player.linear_velocity.x = lerp(player.linear_velocity.x, target_speed, Player.LERP_SPEED)

	if on_floor and Input.is_action_just_pressed(InputSystem.PLAYER_JUMP):
		player.linear_velocity.y = -Player.JUMP_SPEED

func _on_player_respawn() -> void:
	if player.last_checkpoint != Vector2():
		player.global_position = player.last_checkpoint
	else:
		for c in $"/root/Game/Levels".get_children():
			if c.is_in_group("Level"):
				player.global_position = c.get_node("SpawnPosition").global_position

func _on_player_change_facing(direction: int) -> void:
	match direction:
		Player.DirectionFacing.LEFT:
			face_left()
		Player.DirectionFacing.RIGHT:
			face_right()

func face_left() -> void:
	player.sprite.scale.x = -1
	player.spells.position.x = -130

func face_right() -> void:
	player.sprite.scale.x = 1
	player.spells.position.x = 130
