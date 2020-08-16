extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	if !get_parent().has_node("Player"):
		var player = load("res://JesusSaves/src/Player/Player.tscn").instance()
		player.position = position
		get_parent().call_deferred("add_child",player)
