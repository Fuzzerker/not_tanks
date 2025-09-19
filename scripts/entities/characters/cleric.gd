extends "res://scripts/entities/characters/working_character.gd"

func _ready():
	max_stamina = 100
	stamina = 100
	super()

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.CLERIC

func _setup_state_machine() -> void:
	# Override to use ClericStateMachine instead of WorkerStateMachine
	var tml = Engine.get_main_loop().current_scene.find_child("TileMapLayer")
	state_machine = ClericStateMachine.new(self, tml)
