extends Node

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

var characters: Array = []

func _add_character(character) -> void:
	characters.push_back(character)
	
func _get_closest_cleric(pos: Vector2) -> Vector2:
	var closest_cleric = SpatialUtils.find_closest_by_type(characters, pos, EntityTypes.EntityType.CLERIC)
	return closest_cleric.position if closest_cleric else Vector2.ZERO
	
