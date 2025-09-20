extends "res://scripts/entities/base/character.gd"
class_name WorkingCharacter

var effort: int = 100
# Work system (simplified - just holds current work)
var active_work: WorkRequest = null
var last_work: WorkRequest = null

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
	
