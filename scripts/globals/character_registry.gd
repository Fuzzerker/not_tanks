extends Node

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

var characters: Array = []

func _add_character(char) -> void:
	characters.push_back(char)
	
func _get_closest_cleric(pos: Vector2) -> Vector2:
	var closest_cleric = null
	var closest_dist: float = INF
	
	for char in characters:
		if char.entity_type == EntityTypes.EntityType.CLERIC:
			var dist: float = pos.distance_squared_to(char.position)
			if dist < closest_dist:
				closest_dist = dist
				closest_cleric = char
	if closest_cleric != null:
		return closest_cleric.position
	return Vector2.ZERO
	
