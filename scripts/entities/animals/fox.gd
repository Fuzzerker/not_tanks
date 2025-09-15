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
	entity_type = EntityTypes.EntityType.FOX
	AnimalManager._register(self)

func _find_food():
	var rat = AnimalManager._get_closest_rat(position)
	return rat

func _consume_food(food) -> bool:
	AnimalManager._eat_animal(food)
	return true

# Serialization methods (inherits from animal.gd which handles most of it)
func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	# Fox-specific data (if any) would go here
	return data

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	# Fox-specific deserialization (if any) would go here
	
	# Re-register with managers after deserialization
	AnimalManager._register(self)
