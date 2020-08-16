extends Popup

"""
This popup is responsible for presenting the user with a prompt
to enter a new key/joystick entry to map to an action. This will capture
the input event and emit a signal to add a new action, along with the
input event.
"""
func _ready() -> void:
	popup_exclusive = true
	set_process_input(false)

	EventBus.connect("game_reload_i18n", self, "_on_game_reload_i18n")
	EventBus.emit_signal("game_reload_i18n")

func _input(event: InputEvent) -> void:
	# Only continue if one of these
	if !event is InputEventKey && !event is InputEventJoypadButton && !event is InputEventJoypadMotion:
		return

	if !event.is_pressed():
		return

	set_process_input(false)
	visible = false
	EventBus.emit_signal("settings_create_input_binding", event)

func _on_Popup_about_to_show() -> void:
	set_process_input(true)
	get_focus_owner().release_focus()

func _on_CancelButton_pressed():
	visible = false
	set_process_input(false)

func _on_game_reload_i18n() -> void:
#	find_node("Button").text = tr("CANCEL")
#	find_node("Label").text = tr("USE_NEW_CONTROLS")
	pass
