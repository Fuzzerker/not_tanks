extends Node

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

var animals: Array = []

func _register(animal) -> void:
	animals.push_back(animal)

func _get_closest_rat(pos: Vector2):
	return SpatialUtils.find_closest_by_type(animals, pos, EntityTypes.EntityType.RAT)
			

func _eat_animal(animal) -> void:
	animals.erase(animal)
	animal.queue_free()
