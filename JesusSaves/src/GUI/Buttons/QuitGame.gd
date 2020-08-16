extends Panel

onready var event_bus = $"/root/EventBus"

func _ready() -> void:
	event_bus.connect("toggle_main_menu", self, "_on_toggle_main_menu")

func _on_toggle_main_menu() -> void:
	if !visible:
#		$YesButton.grab_focus()
		event_bus.emit_signal("pause_game")
	else:
		event_bus.emit_signal("resume_game")

	visible = !visible

func _on_OptionsButton_pressed() -> void:
	pass

func _on_MusicButton_toggled(button_pressed) -> void:
	get_node("/root/MainScene/JesusStrike").playing = button_pressed

func _on_QuitButton_pressed() -> void:
	event_bus.emit_signal("quit_game")

func _on_ResumeButton_pressed() -> void:
	EventBus.emit_signal("game_resume")
	visible = false
