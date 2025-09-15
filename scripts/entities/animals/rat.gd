extends "res://scripts/entities/animals/animal.gd"

# Rat - Herbivorous animal that eats plants

func _ready() -> void:
	super()
	max_health = 100
	health = 100
	hunger_threshold = 50  # Rats eat when less than 50% hungry
	type = "rat"
	speed = 220
	AnimalManager._register(self)

func _find_food():
	return PlantManager._get_closest_plant(position)

func _consume_food(food) -> void:
	current_food_target = PlantManager._drain_plant(food)
