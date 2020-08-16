extends Node

# Player Actions
const PLAYER_WEAPON_UP: String = "weapon_up"
const PLAYER_WEAPON_DOWN: String = "weapon_down"
const PLAYER_LIGHT_ATTACK_1: String = "light_attack"
const PLAYER_MAGIC_ATTACK_1: String = "magic_attack"
const PLAYER_JUMP: String = "jump"
const PLAYER_MOVE_LEFT: String = "left"
const PLAYER_MOVE_RIGHT: String = "right"

# UI Actions
const TOGGLE_MAIN_MENU: String = "toggle_main_menu"

func _ready() -> void:
	# warning-ignore:return_value_discarded
	EventBus.connect("quit_game", self, "_on_quit_game")
	# warning-ignore:return_value_discarded
	EventBus.connect("pause_game", self, "_on_pause_game")
	# warning-ignore:return_value_discarded
	EventBus.connect("resume_game", self, "_on_resume_game")

func _input(_event: InputEvent) -> void:
	check_toggle_main_menu()

func _on_quit_game() -> void:
	get_tree().quit()

func _on_pause_game() -> void:
	get_tree().paused = true

func _on_resume_game() -> void:
	get_tree().paused = false

func check_toggle_main_menu() -> void:
	if Input.is_action_just_pressed(TOGGLE_MAIN_MENU):
		EventBus.emit_signal(TOGGLE_MAIN_MENU)
