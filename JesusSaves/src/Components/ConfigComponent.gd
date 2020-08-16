extends Node

var NODE_PATH_GAME: NodePath = "/root/Game"
var NODE_PATH_UI: NodePath = "/root/Game/UI"
var node_path_levels: NodePath = "/root/Game/Levels"
var node_path_main_menu: NodePath = "/root/Game/Levels/MainMenu"
var node_path_bgm: NodePath = "/root/Game/Music"

# preload() requires string const, so this doesnt work
#var SCRIPT_PATH_GAME: String = "res://JesusSaves/src/Game/Game.gd"

var FILE_PATH_SETTINGS: String = "user://settings.save"

var SCENE_PATH_OPTIONS_MENU: String = "res://JesusSaves/src/UserInterface/OptionsMenu/OptionsMenu.tscn"
var SCENE_PATH_OPTIONS_VIDEO: String = "res://JesusSaves/src/UserInterface/OptionsMenu/OptionsVideo.tscn"
var SCENE_PATH_OPTIONS_SOUND: String = "res://JesusSaves/src/UserInterface/OptionsMenu/OptionsSound.tscn"
var SCENE_PATH_OPTIONS_CONTROLS: String = "res://JesusSaves/src/UserInterface/OptionsMenu/OptionsControls.tscn"

var video: VideoConfig = VideoConfig.new()
var sound: SoundConfig = SoundConfig.new()
var key_binding: KeyBindingConfig = KeyBindingConfig.new()

class VideoConfig extends Resource:
	var fullscreen: bool = false
	var borderless: bool = false
	var scale: float = 0.0

class SoundConfig extends Resource:
	var masterVolume: float = 0.0
	var musicVolume: float = 0.0
	var sfxVolume: float = 0.0

class KeyBindingConfig extends Resource:
	var bindings: Array = []
