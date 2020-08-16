extends Node

var main_menu: bool = false setget set_main_menu
var options: bool = false setget set_options
var controls: bool = false setget set_controls
var languages: bool = false setget set_languages
var paused: bool = false setget set_paused

func set_main_menu(value: bool) -> void:
	main_menu = value
	EventBus.emit_signal("game_main_menu", main_menu)

func set_options(value: bool) -> void:
	options = value
	EventBus.emit_signal("game_options", options)

func set_controls(value: bool) -> void:
	controls = value
	EventBus.emit_signal("game_controls", controls)

func set_languages(value: bool) -> void:
	languages = value
	EventBus.emit_signal("game_languages", languages)

func set_paused(value: bool) -> void:
	paused = value
	EventBus.emit_signal("game_paused", paused)
