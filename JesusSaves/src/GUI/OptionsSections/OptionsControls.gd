extends VBoxContainer

var action_bind: PackedScene = preload("../ReBindSection/ActionBind.tscn")
var control_bind: PackedScene = preload("../ReBindSection/ControlBind.tscn")
var action_name_path: String = "Name" #find_node()
var action_add_path: String = "AddAction" #find_node()
var control_name_path: String = "Name"
var control_remove_path: String = "RemoveAction"

# To know which node to add ControlBinds
var action_nodes: Dictionary = {}

# Find node to keep it flexible
onready var action_list: VBoxContainer = find_node("ActionList")
onready var popup: Popup = find_node("Popup")

func _ready() -> void:
	set_action_list()
	EventBus.connect("game_controls", self, "_on_game_controls")
	EventBus.connect("game_reload_i18n", self, "_on_game_reload_i18n")
	EventBus.emit_signal("game_reload_i18n")

func _on_game_controls(value: bool) -> void:
	visible = value

func set_action_list() -> void:
	# Just in case resetting everything
	action_nodes.clear()

	for action in Settings.actions:
		var action_node: VBoxContainer = action_bind.instance()

		action_list.add_child(action_node)

		# Save node for easier access
		action_nodes[action] = action_node

		# Name of actions
		var name_label: Label = action_node.find_node("Name")

		# Used for adding new ControlBind
		var add_button: Button = action_node.find_node("AddAction")
		name_label.text = action

		add_button.connect("pressed", self, "add_control", [action])

		# emit to send node to ScrollContainer
		EventBus.emit_signal("new_scroll_container_button", action_node)

		set_control_list(action)

func set_control_list(action: String) -> void:
	# Dictionary of InputEvents for each action
	var action_controls: Array = Settings.action_controls[action]
	var index: int = 0

	# Maybe just list would be OK but to be sure it goes right it's range()
	for name in range(action_controls.size()):
		new_bind(action, action_controls[index])
		index += 1

# Adding bound InputEvent in the list
func new_bind(action: String, event: InputEvent) -> void:
	var event_node: HBoxContainer = control_bind.instance()

	# Action represented parent node
	var parent: VBoxContainer = action_nodes[action]
	parent.add_child(event_node)

	var bind_name: Label = event_node.find_node("Name")
	var remove_button: Button = event_node.find_node("RemoveAction")

	bind_name.text = get_input_event_name(event)

	# name, event, node
	remove_button.connect("pressed", self, "remove_control", [[action, event, event_node]])

	# emit to send node to ScrollContainer
	EventBus.emit_signal("new_scroll_container_button", event_node)

func get_input_event_name(event: InputEvent) -> String:
	var text: String = ""

	if event is InputEventKey:
		text = "Keyboard: " + event.as_text()
	elif event is InputEventJoypadButton:
		text = "Gamepad: "
		if Input.is_joy_known(event.device):
			text+= str(Input.get_joy_button_string(event.button_index))
		else:
			text += "Btn. " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		text = "Gamepad: "
		if Input.is_joy_known(event.device):
			text+= str(Input.get_joy_axis_string(event.axis)) + " "
		else:
			text += "Axis: " + str(event.axis) + " "
		text += str(round(event.axis_value))

	return text

func add_control(name: String) -> void:
	popup.popup()
	yield(popup, "NewControl")

	if popup.NewEvent == null:
		return

	var event: InputEvent = popup.NewEvent
	Settings.action_controls[name].push_back(event)
	InputMap.action_add_event(name, event)
	new_bind(name, event)

func remove_control(binds: Array) -> void:
	var name: String = binds[0]
	var event: InputEvent = binds[1]
	var node: HBoxContainer = binds[2]

	var index: int = Settings.action_controls[name].find(event)
	Settings.action_controls[name].remove(index)
	InputMap.action_erase_event(name, event)
	node.queue_free()

func _on_Default_pressed() -> void:
	Settings.default_controls()

	for action in action_nodes:
		action_nodes[action].queue_free()

	set_action_list()

func _on_Back_pressed() -> void:
	GameData.controls = false

#Localization
func _on_game_reload_i18n() -> void:
	find_node("Default").text = tr("DEFAULT")
	find_node("Back").text = tr("BACK")
	find_node("Actions").text = tr("ACTIONS")

	#Action names
	for action in Settings.actions:
		action_nodes[action].find_node("Name").text = tr(action)
