class_name WorkerStateMachine
extends StateMachine

var character: WorkingCharacter
var idle_state: IdleState
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
	idle_state = IdleState.new(character)
	work_state = WorkState.new(character, tile_map_layer)
	rest_state = RestState.new(character)
	eat_state = EatState.new(character)

func _setup_transitions():
	# From null to idle
	add_transition(
		null,
	 	idle_state,
		func() -> bool:return true,
		"initial transition to idle" )
		
		
	#do work if you are idle and have work
	add_transition(
		idle_state, 
		work_state, 
		func():
			#print("checking transition to work ", character.active_work, " stam ", ConditionFactory.stamina_low(character).call())
			return character.active_work != null and not ConditionFactory.stamina_low(character).call(),
		"Idle but have work and stamina "
	)
	
	# From Work to Rest (when stamina is low)
	add_transition(
		work_state,
		rest_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_low(character),
			func(): 
				var character_has_house = character.house != null
				print("character_has_house ", character_has_house)
				return character_has_house,
			]),
		"Stamina depleted"
	)
	
	# From Work to Idle (when stamina is low but no house)
	add_transition(
		work_state,
		idle_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_low(character),
			func(): return character.house == null]),
		"stamina is low but no house"
	)
	
	#from Idle to REST - if idle and no stamina but has house
	add_transition(
		idle_state,
		rest_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_low(character),
			func(): return character.house != null]),
		"idle and no stamina but has house"
	)
	
	# From Rest to Work (when stamina is restored and work is available)
	#add_transition(
		#rest_state,
		#work_state,
		#ConditionFactory.and_condition([
			#ConditionFactory.stamina_full(character),
			#func(): character.active_work != null,
		#]),
		#"Stamina restored and work available"
	#)
	
	# From Rest to Idle (when stamina is restored but no work)
	add_transition(
		rest_state,
		idle_state,
		ConditionFactory.and_condition([
			ConditionFactory.stamina_full(character),
		]),
		"Stamina restored but no work"
	)
	

	
	# From Work to Idle (when work is completed)
	add_transition(
		work_state,
		idle_state,
		func() -> bool: 
			#print("active_work ", character.active_work)
			return character.active_work == null,
		"Work completed"
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

	
