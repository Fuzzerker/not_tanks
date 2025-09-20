extends "res://scripts/entities/base/living_entity.gd"
class_name Character

var character_name: String = ""

var state_machine: StateMachine

var house: Building = null

func _ready() -> void:
	character_name = NameGenerator._generate_name()
	base_speed = 1000.0
	_setup_character_type()
	CharacterRegistry._add_character(self)
	TimeManager._register(_process_tick)
	_setup_state_machine()
	super()

	
func _process_tick():
	if state_machine != null:
		state_machine.execute()

func _setup_character_type() -> void:
	# Override in subclasses to set entity_type
	pass

func _setup_state_machine() -> void:
	# Override in subclasses to set up character-specific state machine
	pass
