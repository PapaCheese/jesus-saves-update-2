extends Node

# Probably all GUI controlling functions will be there to separate mixing functions

var focus_group: Array
var buttons_sections: Dictionary = {}

# Use to detect if no button in focus
onready var focus_detect: Control = Control.new()

func _ready() -> void:
	# Without this it can't detect buttons in focus
	add_child(focus_detect)

	EventBus.connect("game_refocus", self, "_on_game_refocus")
	EventBus.connect("gui_toggle_options_main", self, "_on_gui_toggle_options_main")
	EventBus.connect("gui_toggle_options_i18n", self, "_on_gui_toggle_options_i18n")
	EventBus.connect("gui_toggle_options_controls", self, "_on_gui_toggle_options_controls")

	pause_mode = Node.PAUSE_MODE_PROCESS
	set_process_unhandled_key_input(true)

# Workaround to get initial focus
func gui_collect_focus_group() -> void:
	focus_group.clear()
	focus_group = get_tree().get_nodes_in_group("focus_group")

	# Save references to call main buttons in sections
	for btn in focus_group:
		var groups: Array = btn.get_groups()

		if groups.has("MainMenu"):
			buttons_sections["MainMenu"] = btn

		if groups.has("Pause"):
			buttons_sections["Pause"] = btn

		if groups.has("OptionsMain"):
			buttons_sections["OptionsMain"] = btn

		if groups.has("OptionsControls"):
			buttons_sections["OptionsControls"] = btn

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Not in main menu
		if !GameData.main_menu:
			if !GameData.paused:
				GameData.paused = true
			elif !GameData.options:
				GameData.paused = false
	elif focus_detect.get_focus_owner() != null:
		# There's already button in focus
		return
	elif event.is_action_pressed("ui_right"):
		EventBus.emit_signal("game_refocus")
	elif event.is_action_pressed("ui_left"):
		EventBus.emit_signal("game_refocus")
	elif event.is_action_pressed("ui_up"):
		EventBus.emit_signal("game_refocus")
	elif event.is_action_pressed("ui_down"):
		EventBus.emit_signal("game_refocus")

func _on_game_refocus() -> void:
	var btn: Button

	if GameData.main_menu:
		if GameData.options:
			if GameData.controls:
				btn = buttons_sections.OptionsControls
			else:
				btn = buttons_sections.OptionsMain
		else:
			btn = buttons_sections.MainMenu
	else:
		if GameData.options:
			if GameData.controls:
				btn = buttons_sections.OptionsControls
			else:
				btn = buttons_sections.OptionsMain
		else:
			if GameData.paused:
				btn = buttons_sections.Pause

	if btn != null:
		btn.grab_focus()

func _on_gui_toggle_options_main(value: bool) -> void:
	pass

func _on_gui_toggle_options_i18n(value: bool) -> void:
	pass

func _on_gui_toggle_options_controls(value: bool) -> void:
	pass
