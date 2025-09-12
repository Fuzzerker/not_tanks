extends Node


var characters:Array = []

func _add_character(char):
	characters.push_back(char)
	
func _get_closest_cleric(pos: Vector2):
	var closest_cleric = null
	var closest_dist = INF
	
	for char in characters:
		if char.type == "cleric":
			var dist = pos.distance_squared_to(char.ref.position)
			if dist < closest_dist:
				closest_dist = dist
				closest_cleric = char
	if closest_cleric != null:
		return closest_cleric.ref.position
	
