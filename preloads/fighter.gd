extends "res://scripts/entities/characters/fighting_character.gd"

class_name Fighter

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.FIGHTER

func _setup_state_machine() -> void:
	# Set up melee state machine for fighter
	state_machine = MeleeStateMachine.new(self)
