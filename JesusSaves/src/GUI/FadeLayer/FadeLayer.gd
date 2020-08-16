extends CanvasLayer

"""
FadeLayer

Enables a 'fade to black' effect when switching scenes
"""

var percent: float = 0.0 setget set_percent

onready var color_rect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = percent

func set_percent(value: float) -> void:
	percent = clamp(value, 0.0, 1.0)

	# Fade logic
	color_rect.modulate.a = percent
