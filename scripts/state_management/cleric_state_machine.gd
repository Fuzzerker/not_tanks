class_name ClericStateMachine
extends StateMachine

var character: WorkingCharacter
var arbolize_state: ArbolizeState
var work_state: WorkState
var rest_state: RestState
var eat_state: EatState
var tile_map_layer: TileMapLayer

func _init(char: WorkingCharacter, tm: TileMapLayer):
	character = char
	tile_map_layer = tm
	_setup_states()
	_setup_transitions()

func _setup_states():
	arbolize_state = ArbolizeState.new(character)
	work_state = WorkState.new(character, tile_map_layer)
	rest_state = RestState.new(character)
	eat_state = EatState.new(character)

func _setup_transitions():
	# From null to arbolize (initial state)
	add_transition(
		null,
		arbolize_state,
		func() -> bool: return true,
		"initial transition to arbolize"
	)
	
	# From Arbolize to Rest (when stamina is low and has house)
	add_transition(
		arbolize_state,
		rest_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_low(character),
			func(): return character.house != null
		]),
		"Stamina depleted while arbolizing"
	)
	
	# From Arbolize to Eat (when hunger is critical)
	add_transition(
		arbolize_state,
		eat_state,
		ConditionFactory.hunger_critical(character),
		"Hunger critical while arbolizing"
	)
	
	# From Rest to Arbolize (when stamina is restored)
	add_transition(
		rest_state,
		arbolize_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_full(character)
		]),
		"Stamina restored and returned to start position"
	)
	
	# From Eat to Arbolize (when hunger is satisfied)
	add_transition(
		eat_state,
		arbolize_state,
		func() -> bool: return character.hunger > 50,
		"Hunger satisfied, return to arbolizing"
	)
	
	# Any state to Eat (when hunger is critical)
	add_any_transition(
		eat_state,
		ConditionFactory.hunger_critical(character),
		"hunger critical"
	)
