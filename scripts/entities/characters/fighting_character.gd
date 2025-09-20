extends "res://scripts/entities/base/character.gd"
class_name FightingCharacter

# Base class for all fighting characters
# Similar to working_character but for combat-focused entities

var combat_skill: int = 50
var max_combat_skill: int = 100
var weapon_damage: int = 25

func _process_tick():
	if state_machine != null:
		state_machine.execute()

func _setup_character_type() -> void:
	# Override in subclasses to set entity_type
	pass

func _setup_state_machine() -> void:
	# Override in subclasses to set up character-specific state machine
	pass
