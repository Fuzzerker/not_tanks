extends "res://scripts/idler.gd"

# Base class for all living entities with health and hunger systems
class_name LivingEntity

# Health and hunger system
var max_health: int = 100
var health: int = 100
var hunger: int = 100
var hungry_interval: float = 1.0
var hunger_threshold: int = 50  # When to start looking for food

# Internal timer for hunger decay
var _time_accumulator: float = 0.0

# Entity type identifier
var type: String = "living_entity"

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
	info["type"] = type
	return info

func _process(delta: float) -> void:
	pos_label.text = str(Vector2i(global_position))
	
	# Handle idle behavior if not eating
	if is_idle:
		super._process(delta)
	
	# Update hunger and health
	_update_hunger_and_health(delta)
	
	# Handle eating behavior if hungry
	if hunger < hunger_threshold:
		_handle_hunger(delta)
	else:
		if not is_idle:
			_start_idle()
	
	# Check for death
	if health <= 0:
		_die()

# Virtual method to be overridden by subclasses
func _handle_hunger(delta: float) -> void:
	pass

# Virtual method to be overridden by subclasses  
func _eat(food) -> void:
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
