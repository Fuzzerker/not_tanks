extends "res://scripts/entities/base/idler.gd"

# Base class for all living entities with health and hunger systems

# Health and hunger system
var max_health: int = 100
var health: int = 100
var hunger: int = 100
var hungry_interval: float = 1.0
var hunger_threshold: int = 50  # When to start looking for food
var type = "living_entity"
# Internal timer for hunger decay
var _time_accumulator: float = 0.0

func _ready() -> void:
	super()
	InformationRegistry._register(self)

func _get_info() -> Dictionary:
	var info = super()
	info["max_health"] = max_health
	info["health"] = health
	info["hunger"] = hunger
	info["hungry_interval"] = hungry_interval
	info["hunger_threshold"] = hunger_threshold
	return info

#returns true if the caller is free to do something else
#returns false if this entity is busy doing something regarding its living function
func _process_live(delta: float, is_idle: bool) -> bool:
	pos_label.text = str(Vector2i(global_position))
	_update_hunger_and_health(delta)
	
	if hunger < hunger_threshold:
		_handle_hunger(delta)
		
	if health <= 0:
		_die()
		return false
	
	if is_idle:
		super._process(delta)
	return hunger > hunger_threshold
		

# Virtual method to be overridden by subclasses
func _handle_hunger(_delta: float) -> void:
	print("hungry, passing to subclass")
	pass

# Virtual method to be overridden by subclasses  
func _eat(_food) -> void:
	pass

func _update_hunger_and_health(delta: float) -> void:
	_time_accumulator += delta
	
	if _time_accumulator >= hungry_interval:
		_time_accumulator -= hungry_interval
		hunger -= 1
		
		# Prevent hunger from going below 0
		if hunger <= 0:
			hunger = 0
			health -= 1
		
		# Regenerate health when well-fed
		if hunger > 3:
			health += 1
			if health > max_health:
				health = max_health

func _die() -> void:
	queue_free()
