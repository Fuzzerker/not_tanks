extends "res://scripts/entities/base/character.gd"

# Base class for all undead creatures
# Similar to fighting_character but for undead entities

var undead_power: int = 60
var max_undead_power: int = 100
var necromancy_resistance: int = 30

func _process_tick():
	if state_machine != null:
		state_machine.execute()

func _setup_character_type() -> void:
	# Override in subclasses to set entity_type
	pass

func _setup_state_machine() -> void:
	# Override in subclasses to set up character-specific state machine
	pass
