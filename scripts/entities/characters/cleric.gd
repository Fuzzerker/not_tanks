extends "res://scripts/entities/characters/working_character.gd"

# Worker - Human character specialized in digging and planting
# Inherits all common working character functionality from WorkingCharacter

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.WORKER
