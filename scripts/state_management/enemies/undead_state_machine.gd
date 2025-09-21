extends StateMachine

# State machine for undead creatures
class_name UndeadStateMachine

var character: Character
var inactive_state: InactiveState

func _init(character_node: Character):
	character = character_node
	_setup_states()
	_setup_transitions()

func _setup_states():
	inactive_state = InactiveState.new(character)

func _setup_transitions():
	# Start in inactive state
	add_transition(
		null,
		inactive_state,
		func() -> bool: return true,
		"initial transition to inactive"
	)
	
	# For now, undead creatures only have the inactive state
	# Future transitions can be added here when more states are implemented
