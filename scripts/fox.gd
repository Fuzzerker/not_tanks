extends "res://scripts/animal.gd"

# Fox - Carnivorous animal that hunts rats

func _ready() -> void:
	super()
	speed = 300
	MAX_OFFSET = 200
	max_health = 300
	health = 300
	hunger_threshold = 75  # Foxes hunt when less than 75% hungry
	type = "fox"
	AnimalManager._register(self)

func _find_food():
	return AnimalManager._get_closest_rat(position)

func _consume_food(food) -> void:
	AnimalManager._eat_animal(food)
