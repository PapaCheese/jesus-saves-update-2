extends StateMachine.State

func _init() -> void:
	name = "IDLE"

func _process(_delta: float) -> void:
	# Start patrolling when the player gets closer to us
	if target.should_patrol():
		target.state_machine.pop()
		target.state_machine.push_create(ZombieStates.PatrolState, [])

func _on_enter_state() -> void:
	if target.debug:
		target.say("No Player Nearby")

func _on_leave_state() -> void:
	if target.debug:
		target.say("Player Nearby")
