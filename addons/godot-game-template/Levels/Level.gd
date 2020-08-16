extends Node2D

export(String, FILE, "*.tscn") var next_scene: String

func _on_Button_pressed() -> void:
	EventBus.emit_signal("game_select_scene", next_scene)
