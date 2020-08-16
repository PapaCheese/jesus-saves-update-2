extends Area2D

export(float) var damage: float = 15.0

var looted: bool = false

# warning-ignore:unused_class_variable
onready var sprite: Sprite = $Sprite
onready var label: Label = $Label
onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	label.text = str(damage) + " DAMAGE"

func _on_SkillPrayer_body_entered(body):
	if !looted and body.is_in_group("Player"):
		looted = true
		animation_player.play("looted")
		EventBus.emit_signal("player_get_weapon", self)
