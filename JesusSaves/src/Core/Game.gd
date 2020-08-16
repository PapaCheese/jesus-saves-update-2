extends Node2D

"""
Game

Top-level game scene. Entry-point for the game.
"""

enum FadeState {
	IDLE,
	FADE_OUT,
	FADE_IN
}

var next_scene: PackedScene
var fade_state: int = FadeState.IDLE
var current_scene: PackedScene

# Moved from GameData
var main_menu: bool = false
var options: bool = false
var controls: bool = false
var languages: bool = false
var paused: bool = false

onready var fade_layer = $FadeLayer
onready var fade_tween = $FadeLayer/FadeTween
onready var levels = $Levels
onready var current_scene_instance = $Levels.get_child($Levels.get_child_count() - 1)

func _ready() -> void:
	# TODO: fix tight coupling, should be event
	GuiSystem.gui_collect_focus_group()

func _on_FadeTween_tween_completed(object, key) -> void:
	# TODO: this should go into GameSystem, handled via event

	match fade_state:
		FadeState.IDLE:
			pass

		FadeState.FADE_OUT:
			if next_scene == null:
				push_warning("Game: Not loaded, please wait!")
				yield(EventBus, "game_scene_is_loaded")

			# TODO: fix tight coupling, should be event
			GameSystem.change_scene()

			fade_state = FadeState.FADE_IN
			fade_tween.interpolate_property(fade_layer, "percent", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.0)
			fade_tween.start()

		FadeState.FADE_IN:
			fade_state = FadeState.IDLE
