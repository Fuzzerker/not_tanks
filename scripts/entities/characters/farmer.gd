extends "res://scripts/entities/characters/working_character.gd"

# Farmer - Human character specialized in planting and watering
# Inherits all common working character functionality from WorkingCharacter

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.FARMER

func _find_work() -> void:
	# Pass farmer type to work queue so it only returns plant/agua work
	active_work = WorkQueue._claim_work(position, EntityTypes.EntityType.FARMER)
	if active_work:
		action = Action.WORK
		target_position = active_work.position
