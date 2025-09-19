extends "res://scripts/entities/characters/working_character.gd"

# Cutter - Human character specialized in chopping trees
# Inherits all common working character functionality from WorkingCharacter

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.CUTTER

#func _find_work() -> void:
	## Pass cutter type to work queue so it only returns chop work
	#active_work = WorkQueue._claim_work(position, EntityTypes.EntityType.CUTTER)
	#if active_work:
		#action = Action.WORK
		#target_position = active_work.position
