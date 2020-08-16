extends Control

"""
OptionsVideo

Listen for UI events, fire signals to EventBusOptions.
"""

func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	EventBusOptions.emit_signal("video_toggle_fullscreen", button_pressed)

func _on_Borderless_toggled(button_pressed: bool) -> void:
	EventBusOptions.emit_signal("video_toggle_borderless", button_pressed)

func _on_ScaleDown_pressed() -> void:
	EventBusOptions.emit_signal("video_scale_down")

func _on_ScaleUp_pressed() -> void:
	EventBusOptions.emit_signal("video_scale_up")
