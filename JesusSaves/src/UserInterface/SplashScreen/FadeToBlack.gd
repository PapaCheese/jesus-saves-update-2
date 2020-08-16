extends ColorRect

var game
onready var tween: Tween = $Tween

func _on_Tween_tween_all_completed() -> void:
	get_tree().paused = false
	if color == Color(0, 0, 0, 1):
		$"/root/Game/Levels".add_child(game.instance())
		$"../Splash".hide()
#		$"../../GUI/Health".visible = true
#		$"../../GUI/Divinity".visible = true
#		$"../../GUI/Halos".visible = true
		tween.interpolate_property(
			self,
			"color",
			Color(0, 0, 0, 1),
			Color(0, 0, 0, 0),
			2,
			Tween.TRANS_QUART,
			Tween.EASE_OUT
		)
		tween.start()

func start_game():
	game = load("res://JesusSaves/src/Level/Level1.tscn")
	tween.interpolate_property(
		self,
		"color",
		Color(0, 0, 0, 0),
		Color(0, 0, 0, 1),
		1,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween.start()
