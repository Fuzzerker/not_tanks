extends Node

var animals: Array = []


func _register(animal):
	animals.push_back(animal)

func _get_closest_rat(pos):
	var closest_rat = null
	var closest_dist := INF
	
	for animal in animals:
		if animal.get("type") != "rat":
			continue
		var dist = pos.distance_squared_to(animal.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_rat = animal

func _eat_animal(animal):
	animals.erase(animal)
	animal.queue_free()
