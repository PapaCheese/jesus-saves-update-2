extends Node2D

"""
This is a container for all systems, and controls loading various systems (in order).

Disabling a system should disable that particular system functionality from running, theoretically the
rest of the game would still work.
"""
var _systems = {
	"InputSystem": preload("../System/InputSystem.gd").new(),
	"SaveSystem": preload("../System/SaveSystem.gd").new(),
	"PlayerMovementSystem": preload("../System/PlayerMovementSystem.gd").new(),
	"PlayerAttackSystem": preload("../System/PlayerAttackSystem.gd").new(),
	"PlayerAbilitySystem": preload("../System/PlayerAbilitySystem.gd").new(),
	"PlayerAnimationSystem": preload("../System/PlayerAnimationSystem.gd").new()
}

func _ready() -> void:
	for name in _systems:
		_systems[name].name = name
		add_child(_systems[name])
