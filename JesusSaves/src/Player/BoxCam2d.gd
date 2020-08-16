extends Camera2D

class_name BoxCam2D

signal out_of_the_box

export var player: NodePath = ""

var player_pos: Vector2 = Vector2(0, 0)
var box: Vector2 = Vector2(0, 0)
var design_res: Vector2

onready var player_node: KinematicBody2D = get_node(player)

func _ready() -> void:
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")

	design_res = Vector2(width, height)
	print("DEBUG: width=", width, ", height=", height)

	if player == "":
		print("BoxCam2D: Assign Player Node in BoxCam2D using Inspector.")
		queue_free()
		return
	elif !current:
		print("BoxCam2D: Set 'Current' Enabled or it won't work.'")

	set_box_pos()

	if connect("out_of_the_box", self, "set_box_pos"):
		print("Box_Cam: Failed To Connet Signal")

func _physics_process(_delta: float) -> void:
	player_pos = player_node.position

	var current_box = Vector2(floor(player_pos.x / design_res.x), floor(player_pos.y / design_res.y))

	if current_box.x != box.x or current_box.y != box.y:
		emit_signal("out_of_the_box")
		box = current_box

func set_box_pos():
	var box_pos_x = (design_res.x * floor(player_pos.x / design_res.x))
	var box_pos_y = (design_res.y * floor(player_pos.y / design_res.y))

	position.x = design_res.x / 2 + box_pos_x
	position.y = design_res.y / 2 + box_pos_y
