extends Control

"""
PauseMenu

Displays overlay menu in-game to resuem, restart, change options, return to main menu, or exit the game.

Supports i18n and listens on the `game_reload_i18n` signal.

Note: Restart button is disabled as it doesnt really make sense, not implemented.
"""

onready var resume_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/Resume
onready var restart_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/Restart
onready var options_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/Options
onready var main_menu_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/MainMenu
onready var exit_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/Exit

func _ready() -> void:
	EventBus.connect("game_reload_i18n", self, "_on_game_reload_i18n")

func _on_Resume_pressed() -> void:
	EventBus.emit_signal("game_resume")

func _on_Restart_pressed() -> void:
	EventBus.emit_signal("game_restart")

func _on_Options_pressed() -> void:
	EventBus.emit_signal("gui_toggle_options_menu", true)

func _on_MainMenu_pressed() -> void:
	EventBus.emit_signal("gui_toggle_main_menu", true)

func _on_Exit_pressed() -> void:
	EventBus.emit_signal("game_exit")

func _on_game_reload_i18n() -> void:
	resume_button.text = tr("RESUME")
	restart_button.text = tr("RESTART")
	options_button.text = tr("OPTIONS")
	main_menu_button.text = tr("MAIN_MENU")
	exit_button.text = tr("EXIT")
