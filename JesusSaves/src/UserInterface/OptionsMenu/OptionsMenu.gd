extends Control

"""
OptionsMain

Listens for UI events to switch between option panels
"""

func _on_Video_pressed() -> void:
	EventBusOptions.emit_signal("show_screen", "video")

func _on_Sound_pressed() -> void:
	EventBusOptions.emit_signal("show_screen", "sound")

func _on_Controls_pressed() -> void:
	EventBusOptions.emit_signal("show_screen", "controls")

func _on_Back_pressed() -> void:
	EventBusOptions.emit_signal("toggle_options", false)
