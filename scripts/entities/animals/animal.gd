extends "res://scripts/entities/base/living_entity.gd"

# Base class for all animals with eating behavior

var current_food_target = null
var eating_distance: float = 5.0

func _process(delta:float) -> void:
	super._process_live(delta, true)

func _ready() -> void:
	super()
	AnimalManager._register(self)

func _get_info() -> Dictionary:
	var info = super()
	info["current_food_target"] = current_food_target != null
	info["eating_distance"] = eating_distance
	return info

func _handle_hunger(delta: float) -> void:
	
	# Look for food if we don't have a target
	if current_food_target == null:
		current_food_target = _find_food()
		
		# If no food found, go idle
		if current_food_target == null:
			return
		
		# Found food, stop idling and go for it
		target_position = current_food_target.position
		
	
	# Move toward food target
	if current_food_target != null:
		if _has_arrived(eating_distance):
			_eat(current_food_target)
		else:
			_move_toward(delta)

# Virtual method to be overridden by subclasses
func _find_food():
	pass

# Virtual method to be overridden by subclasses
func _consume_food(_food) -> bool:
	return false

func _eat(food) -> void:
	while(hunger < 100):
		var more = _consume_food(food)
		current_food_target = null
		hunger += 1
	
	
	# Reset back to idle after eating
	
