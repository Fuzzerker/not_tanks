extends "res://scripts/entities/base/idler.gd"

# Base class for all working characters (workers, farmers, etc.)
# Handles work system, stamina, and eating mechanics

class_name WorkingCharacter

enum Action { IDLE, WORK, REST, EATING }

var action: Action = Action.IDLE
var previous_action: Action = Action.IDLE
var active_work: WorkRequest = null

var effort: int = 10
var stamina: int = 1000
var max_stamina: int = 100
var rest_distance: float = 60.0
var character_name: String = ""

# Speed scaling based on stamina
var base_speed: float = 100.0  # Full speed when at max stamina
var min_speed: float = 10.0    # Minimum speed when at 0 stamina

# Eating system - working characters eat from stores/food sources
var current_food_source: Node2D = null
var eating_distance: float = 5.0

var arrival_action: Action = Action.IDLE

func _process(delta: float) -> void:
	if target_position != null and not _has_arrived(1):
		_move_toward(delta)
			

func _ready() -> void:
	super()
	character_name = NameGenerator._generate_name()
	base_speed = 100.0
	max_health = 150  # Working characters have moderate health
	health = 150
	hunger_threshold = 30  # Working characters eat when less than 30% hungry (patient)
	
	# Set initial speed based on starting stamina
	_update_speed()
	
	_setup_character_type()
	CharacterRegistry._add_character(self)

# Virtual method for subclasses to set their entity type
func _setup_character_type() -> void:
	# Override in subclasses to set entity_type
	pass

# Update speed based on current stamina level (harsh jumps, not smooth)
func _update_speed() -> void:
	if max_stamina <= 0:
		speed = base_speed
		return
	
	# Calculate stamina percentage
	var stamina_percentage: float = (float(stamina) / float(max_stamina)) * 100.0
	
	# Harsh speed jumps at specific thresholds
	if stamina_percentage <= 0.0:
		speed = min_speed  # 10 speed at 0% stamina
	elif stamina_percentage <= 50.0:
		speed = base_speed * 0.5  # 50 speed at 1-50% stamina  
	else:
		speed = base_speed  # 100 speed at 51-100% stamina

# Helper function to log action changes
func _set_action(new_action: Action, reason: String = "") -> void:
	if new_action != action:
		var old_action_name = Action.keys()[action]
		var new_action_name = Action.keys()[new_action]
		var log_message = "[%s] Action change: %s → %s" % [character_name, old_action_name, new_action_name]
		
		if reason != "":
			log_message += " (Reason: %s)" % reason
		
		# Add context information
		var context_info = []
		if active_work != null:
			context_info.append("has_work=%s" % active_work.type)
		else:
			context_info.append("has_work=false")
		
		context_info.append("stamina=%d/%d" % [stamina, max_stamina])
		context_info.append("speed=%.1f" % speed)
		context_info.append("hunger=%d" % hunger)
		
		if current_food_source != null:
			context_info.append("has_food_source=true")
		
		log_message += " [%s]" % ", ".join(context_info)
		
		#print(log_message)
		
		previous_action = action
		action = new_action

func _get_info() -> Dictionary:
	var info: Dictionary = super()
	info["character_name"] = character_name
	info["effort"] = effort
	info["stamina"] = stamina
	info["max_stamina"] = max_stamina
	info["rest_distance"] = rest_distance
	info["action"] = Action.keys()[action]
	info["current_food_source"] = current_food_source != null
	info["speed"] = speed
	info["base_speed"] = base_speed
	info["speed_ratio"] = "%.1f%%" % ((speed / base_speed) * 100.0)
	return info

func _process_tick(delta: float) -> bool:
	print("action ", action)
	if super(delta):
		print("busy being alive ", action)
		return true
	
	pos_label.text = str(Vector2i(global_position))
	
	if stamina <= 0:
		_switch_to_rest(delta)
		
	if free:
		match action:
			Action.REST:
				_process_rest(delta)
			Action.WORK:
				_process_work(delta)
			Action.IDLE:
				_process_idle(delta)

	return false

				
func _handle_hunger(delta: float) -> void:
	# Working characters have unique eating behavior - they eat from stores/food sources
	if current_food_source == null:
		current_food_source = _find_food_source()
		
		if current_food_source == null:
			return
		
		# Found food source, stop current action and go eat
		target_position = current_food_source.position
		_set_action(Action.EATING, "found food source")
	
	# Move toward food source
	if current_food_source != null:
		if _has_arrived(eating_distance):
			_eat_from_source()

func _find_food_source() -> Node2D:
	# Working characters eat from stores/food sources
	if Resources.food > 0:
		var food_source: Node2D = Node2D.new()
		food_source.position = position  # For now, eat "in place"
		return food_source
	return null

func _eat_from_source() -> void:
	# Working characters consume food from resources
	if Resources.food > 0:
		Resources.food -= 1
		hunger += 30  # Working characters get good nutrition from prepared food
		
		# Cap hunger at 100
		if hunger > 100:
			hunger = 100
		
	current_food_source = null
	if active_work != null:
		_set_action(Action.WORK, "finished eating, returning to work")
	else:
		_set_action(Action.IDLE, "finished eating, no work available")
		_switch_to_idle()

func _process_rest(delta: float) -> void:
	if _has_arrived(rest_distance):
		stamina += 10
		if stamina >= max_stamina:
			stamina = max_stamina
		_update_speed()  # Update speed when stamina changes
		
		if stamina >= max_stamina:
			_set_action(Action.WORK, "stamina restored, ready to work")
			if active_work:
				target_position = active_work.position
		

func _process_work(delta: float) -> void:
	if active_work == null:
		_find_work()
		if active_work == null and stamina == max_stamina:
			_switch_to_idle()
		else: if active_work == null and stamina < max_stamina:
			_switch_to_rest(delta)
		return
	if _has_arrived(5):
		_do_work()

func _process_idle(_delta: float) -> void:
	if active_work == null:
		_find_work()
	
	if stamina > 0 and active_work != null:
		_set_action(Action.WORK, "found work while idle")

func _do_work() -> void:
	if stamina <= 0:
		return
	if WorkQueue._do_work(active_work.cell, effort):
		active_work = null

	stamina -= effort
	_update_speed()  # Update speed when stamina decreases from work

func _find_work() -> void:
	active_work = WorkQueue._claim_work(position, entity_type)
	if active_work:
		action = Action.WORK
		target_position = active_work.position

# --- helpers ---
func _switch_to_idle() -> void:
	_set_action(Action.IDLE, "switching to idle state")
	_start_idle()

func _switch_to_rest(delta: float) -> void:
	var cleric: Vector2 = CharacterRegistry._get_closest_cleric(position)
	if cleric != Vector2.ZERO:
		target_position = cleric
		_set_action(Action.REST, "low stamina, going to cleric")
		_process_rest(delta)
	else: if action != Action.IDLE:
		_set_action(Action.IDLE, "low stamina, no cleric available")
		_start_idle()

# Serialization methods
func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	data["action"] = action
	data["previous_action"] = previous_action
	data["effort"] = effort
	data["stamina"] = stamina
	data["max_stamina"] = max_stamina
	data["rest_distance"] = rest_distance
	data["character_name"] = character_name
	data["eating_distance"] = eating_distance
	data["base_speed"] = base_speed
	data["min_speed"] = min_speed
	# Note: active_work and current_food_source are not serialized as they're runtime references
	return data

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("action"):
		_set_action(data.action, "loaded from save data")
	if data.has("previous_action"):
		previous_action = data.previous_action
	if data.has("effort"):
		effort = data.effort
	if data.has("stamina"):
		stamina = data.stamina
	if data.has("max_stamina"):
		max_stamina = data.max_stamina
	if data.has("rest_distance"):
		rest_distance = data.rest_distance
	if data.has("character_name"):
		character_name = data.character_name
	if data.has("eating_distance"):
		eating_distance = data.eating_distance
	if data.has("base_speed"):
		base_speed = data.base_speed
	if data.has("min_speed"):
		min_speed = data.min_speed
	
	# Update speed based on loaded stamina
	_update_speed()
	
	# active_work and current_food_source will be null on load and found when needed
	
	# Re-register with managers after deserialization
	CharacterRegistry._add_character(self)
	InformationRegistry._register(self)
