extends Panel

onready var DefaultButton: PackedScene = preload("../Buttons/DefaultButton.tscn")
onready var button_parent: HBoxContainer = $"VBoxContainer/MarginContainer/HBoxContainer"

func _ready() -> void:
	EventBus.connect("game_select_locale", self, "_on_game_select_locale")

	for locale in Settings.locales.keys():
		var new_button: Button = DefaultButton.instance()
		button_parent.add_child(new_button)
		new_button.text = "\"" + locale + "\""
		new_button.connect("pressed", self, "_on_button_pressed", [locale])

func _on_game_select_locale(value: bool) -> void:
	visible = value

func _on_button_pressed(value: String) -> void:
	# Settings will emit ReTranslate
	Settings.locale = Settings.locales[value]
