extends "res://scripts/entities/animals/animal.gd"

# Fox - Carnivorous animal that hunts rats

func _ready() -> void:
	super()
	speed = 300
	MAX_OFFSET = 200
	max_health = 300
	health = 300
	hunger = 78
	hunger_threshold = 75  # Foxes hunt when less than 75% hungry
	type = "fox"
	AnimalManager._register(self)

func _find_food():
	print("fox hungry, finding food")
	var rat = AnimalManager._get_closest_rat(position)
	print(rat)
	return rat

func _consume_food(food) -> bool:
	AnimalManager._eat_animal(food)
