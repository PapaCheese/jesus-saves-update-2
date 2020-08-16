extends Node

const DEBUG_MODE: bool = true
var CONFIG_FILE: String = CoreConfig.FILE_PATH_SETTINGS

# OS
var html_mode: bool = false

# SCREEN
var fullscreen: bool = OS.window_fullscreen setget set_fullscreen
var borderless: bool = OS.window_borderless setget set_borderless
var viewport: Viewport
var visible_rect: Rect2
var game_resolution: Vector2
var window_resolution: Vector2
var screen_resolution: Vector2
var screen_aspect_ratio: float
var scale: int = 3 setget set_scale
var max_scale: int

# AUDIO
var volume_master: float = 0.0 setget set_volume_master
var volume_music: float = 0.0 setget set_volume_music
var volume_sfx: float = 0.0 setget set_volume_sfx
var volume_range: float = 24 + 80

# CONTROLS
var actions: Array = ["Right", "Left", "Up", "Down", "Jump"]
var action_controls: Dictionary = {}

# i18n
# Font doesn't have Cyrillic letters for russian
var locales: Dictionary = {
	EN = "en",
	DE = "de",
	ES = "es",
	FR = "fr",
	BR = "pt_BR",
	LV = "lv",
	IT = "it"
}

#var Save / Load
var Settings_loaded: bool = false

onready var locale: String = TranslationServer.get_locale() setget set_locale

func _ready() -> void:
	if OS.get_name() == "HTML5":
		html_mode = true

	get_resolution()
	load_settings()
	get_volumes()
	get_controls()
	#save_settings() #Call this method to trigger Settings saving

# RESOLUTION
func set_fullscreen(value: bool) -> void:
	fullscreen = value
	OS.window_fullscreen = value
	window_resolution = OS.window_size

	if value:
		scale = max_scale

func set_borderless(value: bool) -> void:
	borderless = value
	OS.window_borderless = value

func get_resolution() -> void:
	viewport = get_viewport()
	visible_rect = viewport.get_visible_rect()
	game_resolution = visible_rect.size
	window_resolution = OS.window_size
	screen_resolution = OS.get_screen_size(OS.current_screen)
	screen_aspect_ratio = screen_resolution.x / screen_resolution.y
	max_scale = ceil(screen_resolution.y / game_resolution.y)

func set_scale(value:int) -> void:
	scale = clamp(value, 1, max_scale)
	if scale >= max_scale:
		OS.window_fullscreen = true
		fullscreen = true
	else:
		OS.window_fullscreen = false
		fullscreen = false
		OS.window_size = game_resolution * scale
		OS.center_window()

	get_resolution()
	emit_signal("Resized")

# AUDIO
func get_volumes() -> void:
	var audio_master: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	var audio_music: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	var audio_sfx: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))

	volume_master = ((audio_master + 80)) / volume_range
	volume_music = ((audio_music + 80)) / volume_range
	volume_sfx = ((audio_sfx + 80)) / volume_range

func set_volume_master(volume:float) -> void:
	volume_master = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), lerp(-80, 24, volume_master))

func set_volume_music(volume:float) -> void:
	volume_music = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), lerp(-80, 24, volume_music))

func set_volume_sfx(volume:float) -> void:
	volume_sfx = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), lerp(-80, 24, volume_sfx))

#CONTROLS
func get_controls() -> void:
	if !Settings_loaded:
		default_controls()
	set_actions_info()

func default_controls() -> void:	#Reset to project settings controls
	InputMap.load_from_globals()
	set_actions_info()

func set_actions_info() -> void:
	action_controls.clear()

	for action in actions:
		# Associated controlls to the action
		action_controls[action] = InputMap.get_action_list(action)

func print_events_list(action_list: Array) -> void:
	for event in action_list:
		print(event.as_text())

func set_locale(value: String) -> void:
	locale = value
	TranslationServer.set_locale(value)
	EventBus.emit_signal("game_reload_i18n")

#Save/ Load
#Call this method to trigger Settings saving
func save_settings() -> void:
	var file: File = File.new()
	if !file.open(CONFIG_FILE, File.WRITE):
		push_error("Error opening file")
		return

	var data: Dictionary = get_save_data()
	file.store_line(to_json(data))
	file.close()

func load_settings() -> void:
	# Need to confirm but for now don't use for HTML5
	if html_mode:
		return

	# Json to Dictionary
	var file:File = File.new()

	# We don't have a save to load
	if !file.file_exists(CONFIG_FILE):
		return

	Settings_loaded = true
	if !file.open(CONFIG_FILE, File.READ):
		push_error("Error opening file")
		return

	var data = parse_json(file.get_line())
	file.close()

	# Dictionary to Settings
	set_save_data(data)

func get_save_data() -> Dictionary:
	return {
		inputs = get_input_data(),
		resolution = get_resolution_data(),
		audio = get_audio_data(),
		language = {locale = TranslationServer.get_locale()}
	}

func get_input_data() -> Dictionary:
	var inputs: Dictionary = {}

	for action_name in actions:
		var button_list_data: Dictionary = {}
		var button_list: Array = action_controls[action_name]
		var index: int = 0

		for button in button_list:
			button_list_data[index] = get_button_data(button)
			index += 1

		inputs[action_name] = button_list_data

	return inputs

func get_button_data(event: InputEvent) -> Dictionary:
	var data: Dictionary = {}

	if event is InputEventKey:
		data["EventType"] = "InputEventKey"
		data["scancode"] = event.scancode

	if event is InputEventJoypadButton:
		data["EventType"] = "InputEventJoypadButton"
		data["device"] = event.device
		data["button_index"] = event.button_index

	if event is InputEventJoypadMotion:
		data["EventType"] = "InputEventJoypadMotion"
		data["device"] = event.device
		data["axis"] = event.axis
		data["axis_value"] = event.axis_value

	return data

func set_save_data(data: Dictionary) -> void:
	if data.has("inputs"):
		set_action_controls_default()
		set_input_data(data.inputs)
	if data.has("resolution"):
		set_resolution_data(data.resolution)
	if data.has("audio"):
		set_audio_data(data.audio)
	if data.has("language"):
		set_locale(data.language.locale)

func set_action_controls_default() -> void:
	for action_name in actions:
		action_controls[action_name] = []

func set_input_data(inputs: Dictionary) -> void:
	var action_names: Array = inputs.keys()

	for action_name in action_names:
		var button_list:Array
		var button_names = inputs[action_name].keys()

		for button_name in button_names:
			var button = inputs[action_name][button_name]
			var event: InputEvent = set_button_data(button)
			action_controls[action_name].push_back(event)

	set_input_map()

func set_button_data(button: Dictionary) -> InputEvent:
	var new_event: InputEvent

	match button.EventType:
		"InputEventKey":
			new_event = InputEventKey.new()
			new_event.scancode = button.scancode

		"InputEventJoypadButton":
			new_event = InputEventJoypadButton.new()
			new_event.device = button.device
			new_event.button_index = button.button_index

		"InputEventJoypadMotion":
			new_event = InputEventJoypadMotion.new()
			new_event.device = button.device
			new_event.axis = button.axis
			new_event.axis_value = button.axis_value

	return new_event

func set_input_map() -> void:
	for action_name in actions:
		InputMap.action_erase_events(action_name)

		for event in action_controls[action_name]:
			InputMap.action_add_event(action_name, event)

func get_resolution_data() -> Dictionary:
	return {
		"fullscreen": fullscreen,
		"borderless": borderless,
		"scale": scale
	}

func set_resolution_data(resolution: Dictionary) -> void:
	set_fullscreen(resolution.fullscreen)
	set_borderless(resolution.forderless)
	set_scale(resolution.scale)

func get_audio_data() -> Dictionary:
	return {
		"master": volume_master,
		"music": volume_music,
		"sfx": volume_sfx
	}

func set_audio_data(audio: Dictionary) -> void:
	set_volume_master(audio["master"])
	set_volume_music(audio["music"])
	set_volume_sfx(audio["sfx"])
