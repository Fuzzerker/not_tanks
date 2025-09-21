extends "res://scripts/entities/enemies/undead_entity.gd"

class_name Skellysord

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.UNDEAD_CREATURE

func _setup_state_machine() -> void:
	# Set up undead state machine for Skellysord
	state_machine = UndeadStateMachine.new(self)
