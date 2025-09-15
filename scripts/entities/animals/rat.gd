extends "res://scripts/entities/animals/animal.gd"

# Rat - Herbivorous animal that eats plants

func _ready() -> void:
	super()
	max_health = 10
	health = 10
	hunger_threshold = 90  # Rats eat when less than 50% hungry
	type = "rat"
	speed = 220
	
	
	AnimalManager._register(self)

func _find_food():
	return PlantManager._get_closest_plant(position)

func _consume_food(food) -> bool:
	print("consuming")
	PlantManager._consume_plant(food)
	food.health -= 1
	return food.health > 0

# Serialization methods (inherits from animal.gd which handles most of it)
func serialize() -> Dictionary:
	var data = super.serialize()
	# Rat-specific data (if any) would go here
	return data

func deserialize(data: Dictionary):
	super.deserialize(data)
	# Rat-specific deserialization (if any) would go here
	
	# Re-register with managers after deserialization
	AnimalManager._register(self)
