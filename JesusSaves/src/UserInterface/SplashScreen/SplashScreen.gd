extends Control

func _ready() -> void:
	visible = true
	EventBus.emit_signal("game_pause",true)

func _on_Start_pressed() -> void:
	$"../FadeToBlack".start_game()

func _on_Quit_pressed() -> void:
	EventBus.emit_signal("game_exit")

func _on_NewSave_pressed() -> void:
	$ConfirmClear.visible = true

func _on_Yes_pressed() -> void:
	var dir = Directory.new()
	dir.remove("user://savegame.save")
	$ConfirmClear.visible = false

func _on_No_pressed() -> void:
	$ConfirmClear.visible = false

func hide() -> void:
	$AnimationPlayer.stop()
	visible = false

func _on_Options_pressed() -> void:
	EventBusOptions.emit_signal("toggle_options", true)
