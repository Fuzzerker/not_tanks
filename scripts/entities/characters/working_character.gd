extends "res://scripts/entities/base/living_entity.gd"
class_name WorkingCharacter
# Basic character properties
var character_name: String = ""

# Stamina system
var effort: int = 100
var stamina: int = 1000
var max_stamina: int = 1000

# Speed scaling based on stamina
var base_speed: float = 100.0
var min_speed: float = 10.0

# Eating system
var eating_distance: float = 5.0

# State machine
var state_machine: StateMachine

# Work system (simplified - just holds current work)
var active_work: WorkRequest = null
var last_work: WorkRequest = null
var house: Building = null

func _ready() -> void:
	character_name = NameGenerator._generate_name()
	base_speed = 1000.0
	var root = get_tree().root
	_setup_character_type()
	CharacterRegistry._add_character(self)
	TimeManager._register(_process_tick)
	
	# Initialize state machine based on character type
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
	var tml = Engine.get_main_loop().current_scene.find_child("TileMapLayer")
	
	state_machine = WorkerStateMachine.new(self, tml)
	
