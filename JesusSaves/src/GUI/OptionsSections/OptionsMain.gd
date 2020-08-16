extends VBoxContainer

# need to disable playing sound on initiating faders
var setup: bool = true

onready var master_slider: HSlider = find_node("Master").get_node("HSlider")
onready var music_slider: HSlider = find_node("Music").get_node("HSlider")
onready var sfx_slider: HSlider = find_node("SFX").get_node("HSlider")
onready var resolution_panel: Panel = find_node("ResolutionPanel")
onready var volume_panel: Panel = find_node("VolumePanel")
onready var language_panel: Panel = find_node("LanguagePanel")
onready var test_beep: AudioStream = preload("../../../assets/audio/game-template/TestBeep.wav")
onready var player: AudioStreamPlayer = find_node("Music").get_node("AudioStreamPlayer")

func _ready() -> void:
	# Set up toggles and sliders
	if Settings.html_mode:
		find_node("Borderless").visible = false
		find_node("Scale").visible = false

	set_resolution()
	set_volume_sliders()

	# Just in case project saved with visible Languages
	EventBus.emit_signal("game_show_locales", false)

	# Finished fader setup
	setup = false

	EventBus.connect("game_controls", self, "_on_game_controls")
	EventBus.connect("game_languages", self, "_on_game_languages")
	EventBus.connect("game_window_resized", self, "_on_game_window_resized")
	EventBus.connect("game_reload_i18n", self, "_on_game_reload_i18n")

	EventBus.emit_signal("game_reload_i18n")

#### BUTTON SIGNALS ####
func _on_Master_value_changed(value: int) -> void:
	if setup:
		return

	Settings.volume_master = value / 100

	var player: AudioStreamPlayer = find_node("Master").get_node("AudioStreamPlayer")

	player.stream = test_beep
	player.play()

func _on_Music_value_changed(value: int) -> void:
	if setup:
		return

	Settings.volume_music = value / 100

	player.stream = test_beep
	player.play()

func _on_SFX_value_changed(value: int) -> void:
	if setup:
		return

	Settings.volume_sfx = value / 100

	player.stream = test_beep
	player.play()

func _on_Fullscreen_pressed() -> void:
	if setup:
		return

	Settings.fullscreen = find_node("Fullscreen").pressed

func _on_Borderless_pressed() -> void:
	if setup:
		return

	Settings.borderless = find_node("Borderless").pressed

func _on_ScaleUp_pressed() -> void:
	Settings.scale += 1

func _on_ScaleDown_pressed() -> void:
	Settings.scale -= 1

func _on_Resized() -> void:
	set_resolution()

func _on_Controls_pressed() -> void:
	GameData.controls = true

func _on_Back_pressed() -> void:
	Settings.save_settings()
	GameData.options = false

func _on_Languages_pressed() -> void:
	GameData.languages = !GameData.languages
	if !GameData.languages:
		return

	# After choosing language it will trigger ReTranslate
	yield(EventBus, "game_reload_i18n")

	print("Language_choosen")

	GameData.languages = !GameData.languages

# EVENT SIGNALS
func _on_game_controls(value: bool) -> void:
	# because showing controls
	visible = !value

func _on_game_languages(value: bool) -> void:
	resolution_panel.visible = !value
	volume_panel.visible = !value

# Localization
func _on_game_reload_i18n() -> void:
	find_node("Resolution").text = tr("RESOLUTION")
	find_node("Volume").text = tr("VOLUME")
	get_node("HBoxContainer/LanguagePanel/VBoxContainer/Languages").text = tr("LANGUAGES")
	find_node("Fullscreen").text = tr("FULLSCREEN")
	find_node("Borderless").text = tr("BORDERLESS")
	find_node("Scale").text = tr("SCALE")
	find_node("Master").get_node("ScaleName").text = tr("MASTER")
	find_node("Music").get_node("ScaleName").text = tr("MUSIC")
	find_node("SFX").get_node("ScaleName").text = tr("SFX")
	get_node("MarginContainer/VBoxContainer/Languages").text = tr("LANGUAGES")
	find_node("Controls").text = tr("CONTROLS")
	find_node("Back").text = tr("BACK")

# TODO: doesnt do anything?
func set_node_in_focus() -> void:
	var FocusGroup: Array = get_groups()

func set_resolution() -> void:
	find_node("Fullscreen").pressed = Settings.fullscreen
	find_node("Borderless").pressed = Settings.borderless
	# Your logic for scaling

# Initialize volume sliders
func set_volume_sliders() -> void:
	master_slider.value = Settings.volume_master * 100
	music_slider.value = Settings.volume_music * 100
	sfx_slider.value = Settings.volume_sfx * 100
