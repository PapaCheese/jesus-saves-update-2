extends Control

"""
MainMenu

Displays menus for new game, options, and exiting the game.

Supports i18n and listens on the `game_reload_i18n` signal.
"""

func _ready() -> void:
	EventBus.connect("game_reload_i18n", self, "_on_game_reload_i18n")

func _on_NewGame_pressed() -> void:
	EventBus.emit_signal("game_new_game")

func _on_Options_pressed() -> void:
	EventBus.emit_signal("gui_toggle_options_menu", true)

func _on_Exit_pressed() -> void:
	EventBus.emit_signal("game_exit")

# Localization
func _on_game_reload_i18n() -> void:
	find_node("NewGame").text = tr("NEW_GAME")
	find_node("Options").text = tr("OPTIONS")
	find_node("Exit").text = tr("EXIT")
