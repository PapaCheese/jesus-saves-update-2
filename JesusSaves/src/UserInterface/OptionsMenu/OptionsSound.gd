extends Control

"""
OptionsSound

Listens to UI events and emits signal to EventBusOptions.
"""

func _on_Master_value_changed(value: float) -> void:
	EventBusOptions.emit_signal("sound_change_master", value)

func _on_Music_value_changed(value: float) -> void:
	EventBusOptions.emit_signal("sound_change_music", value)

func _on_SFX_value_changed(value: float) -> void:
	EventBusOptions.emit_signal("sound_change_sfx", value)
