class_name MeleeStateMachine
extends StateMachine

var character: Character
var idle_state: IdleState
var rest_state: RestState
var eat_state: EatState

func _init(character_node: Character):
	character = character_node
	_setup_states()
	_setup_transitions()
	

func _setup_states():
	idle_state = IdleState.new(character)
	rest_state = RestState.new(character)
	eat_state = EatState.new(character)

func _setup_transitions():
	# From null to idle
	add_transition(
		null,
	 	idle_state,
		func() -> bool:return true,
		"initial transition to idle" )
		
	# From Idle to REST - if idle and no stamina but has house
	add_transition(
		idle_state,
		rest_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_low(character),
			func(): return character.house != null]),
		"idle and no stamina but has house"
	)
	
	# From Rest to Idle (when stamina is restored)
	add_transition(
		rest_state,
		idle_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_full(character),
		]),
		"Stamina restored"
	)
	
	# Any state to Eat (when hunger is critical)
	add_any_transition(
		eat_state,
		ConditionFactory.hunger_critical(character),
		"hunger critical"
	)
	
	# From Eat to previous state (when hunger is satisfied)
	add_transition(
		eat_state,
		idle_state,  # Default return state
		func() -> bool: return character.hunger > 50,
		"Hunger satisfied"
	)
