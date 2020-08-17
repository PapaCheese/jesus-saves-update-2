extends Area2D

export var level: int = 1

const MAX_LEVEL: int = 9

var level_instance: Node2D
var player
var baseBrightness: float = 0.9
var activated: bool = false

onready var tween: Tween = $Tween
onready var worldEnv: WorldEnvironment = get_node("/root/Game/WorldEnvironment")
onready var event_bus: EventBus = $"/root/EventBus"

func _ready():
	tween.interpolate_property(worldEnv.environment, "adjustment_brightness", 0, baseBrightness, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

func _on_LevelEnd_body_entered(body):
	if !activated and body.is_in_group("Player"):
		activated = true

		if level < MAX_LEVEL:
			var scene: Resource = load("res://JesusSaves/src/Level/Level" + str(level + 1) + ".tscn")
			level_instance = scene.instance()

		player = body
		player.last_checkpoint = Vector2()
		tween.interpolate_property(worldEnv.environment, "adjustment_brightness", baseBrightness, 0, 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.start()

func _on_Tween_tween_all_completed():
	if worldEnv.environment.adjustment_brightness == 0:
		get_parent().get_parent().call_deferred("add_child",level_instance)
		player.global_position = level_instance.get_node("SpawnPosition").global_position
		player.last_checkpoint = player.global_position
		player.level = level

		event_bus.emit_signal("save_game")

		var leftCamLimit = level_instance.get_node("Limiters/LeftCamLimit").global_position.x
		var rightCamLimit = level_instance.get_node("Limiters/RightCamLimit").global_position.x
		var fallLimit = level_instance.get_node("Limiters/FallLimit").global_position.y
		player.set_limits(leftCamLimit, rightCamLimit, fallLimit)
		get_parent().queue_free()
