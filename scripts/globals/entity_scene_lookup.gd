extends Node

func _get_scene_for_entity(entity_type: EntityTypes.EntityType):
	match entity_type:
		EntityTypes.EntityType.FARMER:
			return "res://preloads/farmer.tscn"
