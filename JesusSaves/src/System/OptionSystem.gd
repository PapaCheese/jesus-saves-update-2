extends Node

"""
OptionSystem

Register event handlers for EventBusOptions to handle changing of
options.
"""

const OPTIONS_PANEL: String = "OptionsMenu/Panel/HSplitContainer/OptionsPanel"

onready var ui = get_tree().get_root().get_node(CoreConfig.NODE_PATH_UI)

func _ready() -> void:
	# General
	EventBusOptions.connect("show_screen", self, "_on_show_screen")
	EventBusOptions.connect("toggle_options", self, "_on_toggle_options")

	# Video
	EventBusOptions.connect("video_toggle_fullscreen", self, "_on_video_toggle_fullscreen")
	EventBusOptions.connect("video_toggle_borderless", self, "_on_video_toggle_borderless")
	EventBusOptions.connect("video_scale_down", self, "_on_video_scale_down")
	EventBusOptions.connect("video_scale_up", self, "_on_video_scale_up")

"""
Displays the supported options screens (video, sound, controls)
"""
func _on_show_screen(value: String) -> void:
	clear_options_panel()

	var options_panel: Panel = ui.get_node(OPTIONS_PANEL)

	match value:
		"video":
			options_panel.add_child(load(CoreConfig.SCENE_PATH_OPTIONS_VIDEO).instance())
		"sound":
			options_panel.add_child(load(CoreConfig.SCENE_PATH_OPTIONS_SOUND).instance())
		"controls":
			options_panel.add_child(load(CoreConfig.SCENE_PATH_OPTIONS_CONTROLS).instance())

"""
Toggles the options menu being displayed in the UI
"""
func _on_toggle_options(value: bool) -> void:
	# Closing options menu, just free it and return
	if !value:
		ui.get_node("OptionsMenu").queue_free()
		return

	# Instance OptionsMenu and add to UI
	ui.add_child(load(CoreConfig.SCENE_PATH_OPTIONS_MENU).instance())
	EventBusOptions.emit_signal("show_screen", "video")

func _on_toggle_fullscreen(value: bool) -> void:
	pass

func _on_toggle_borderless(value: bool) -> void:
	pass

func _on_scale_down() -> void:
	pass

func _on_scale_up() -> void:
	pass

"""
Clears all children in the options panel so that we don't display multiple option screens
at the same time.
"""
func clear_options_panel():
	for child in ui.get_node(OPTIONS_PANEL).get_children():
		child.queue_free()
