extends Node

const Game = preload("../Core/Game.gd")

onready var game = get_node(CoreConfig.NODE_PATH_GAME)

func _ready() -> void:
	EventBus.connect("game_pause", self, "_on_game_pause")
	EventBus.connect("game_paused", self, "_on_game_paused")
	EventBus.connect("game_options", self, "_on_game_options")
	EventBus.connect("game_exit", self, "_on_game_exit")
	EventBus.connect("game_select_scene", self, "_on_game_select_scene")
	EventBus.connect("game_change_scene", self, "_on_game_change_scene")
	EventBus.connect("game_restart_scene", self, "_on_game_restart_scene")

func _on_game_pause(value: bool) -> void:
	game.paused = value

func _on_game_paused(value: bool) -> void:
	get_tree().paused = value

func _on_game_select_scene(scene: String) -> void:
	if game.fade_state != Game.FadeState.IDLE:
		return

	print("_on_game_change_scene: ", scene)

	if Settings.HTML5:
		game.next_scene = load(scene)
	else:
		SceneLoader.load_scene(scene, {scene = "Level"})

	game.fade_state = Game.FadeState.FADE_OUT
	game.fade_tween.interpolate_property(game.fade_layer, "percent", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.0)
	game.fade_tween.start()

func _on_game_exit() -> void:
	if game.fade_state != Game.FadeState.IDLE:
		return
	get_tree().quit()

func _on_game_scene_loaded(loaded: PackedScene)->void:
	game.next_scene = loaded.resource

	# Scene fade signal in case it loads longer than fade out
	EventBus.emit_signal("game_scene_is_loaded")

func _on_game_change_scene() -> void:
	"""
	Handle actual scene change
	"""
	if game.next_scene == null:
		return

	# ERROR InputMouseButton something
	print("change_scene: ", game.next_scene)

	# Continue on idle frame
	yield(get_tree(), "idle_frame")

	game.current_scene_instance.free()
	game.current_scene = game.next_scene
	game.next_scene = null
	game.current_scene_instance = game.current_scene.instance()
	game.levels.add_child(game.current_scene_instance)

func _on_game_restart_scene() -> void:
	if game.fade_state != Game.FadeState.IDLE:
		return

	yield(get_tree(), "idle_frame")

	game.current_scene_instance.free()
	game.current_scene_instance = game.current_scene.instance()

	game.levels.add_child(game.current_scene_instance)
