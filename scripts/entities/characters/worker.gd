extends "res://scripts/entities/base/living_entity.gd"

# Worker - Human character with work system, stamina, and unique eating mechanics

enum Action { IDLE, WORK, REST, EATING }

var action: Action = Action.IDLE
var active_work = null

var effort: int = 10
var stamina: int = 1000
var max_stamina: int = 1000
var rest_distance: float = 60.0
var character_name = ""

# Eating system - workers eat from stores/food sources
var current_food_source = null
var eating_distance: float = 5.0

func _ready() -> void:
	super()
	character_name = NameGenerator._generate_name()
	speed = 100.0
	max_health = 150  # Workers have moderate health
	health = 150
	hunger_threshold = 30  # Workers eat when less than 30% hungry (more patient)
	type = "worker"
	CharacterRegistry._add_character(self)

func _get_info() -> Dictionary:
	var info = super()
	info["character_name"] = character_name
	info["effort"] = effort
	info["stamina"] = stamina
	info["max_stamina"] = max_stamina
	info["rest_distance"] = rest_distance
	info["action"] = Action.keys()[action]
	info["current_food_source"] = current_food_source != null
	return info

func _process(delta: float) -> void:
	pos_label.text = str(Vector2i(global_position))
	var free = super._process_live(delta, action == Action.IDLE)
	if stamina <= 10:
		_switch_to_rest(delta)
		
	if free:
		match action:
			Action.REST:
				_process_rest(delta)
			Action.WORK:
				_process_work(delta)
			Action.IDLE:
				_process_idle(delta)
				
func _handle_hunger(delta: float) -> void:
	# Workers have unique eating behavior - they eat from stores/food sources
	if current_food_source == null:
		current_food_source = _find_food_source()
		
		if current_food_source == null:
			return
		
		# Found food source, stop current action and go eat
		target_position = current_food_source.position
		print("Found food source, going to eat")
		action = Action.EATING
	
	# Move toward food source
	if current_food_source != null:
		if _has_arrived(eating_distance):
			_eat_from_source()
		else:
			_move_toward(delta)

func _find_food_source():
	# Workers can eat from stores or food stockpiles
	# For now, let's assume they can eat from a global food resource
	# In a more complex system, this would find actual food buildings
	if Resources.food > 0:
		# Create a virtual food source at the worker's position
		# In a real implementation, this would be a food building
		var food_source = Node2D.new()
		food_source.position = position  # For now, eat "in place"
		return food_source
	return null

func _eat_from_source() -> void:
	# Workers consume food from resources
	if Resources.food > 0:
		Resources.food -= 1
		hunger += 30  # Workers get more nutrition from prepared food
		
		# Cap hunger at 100
		if hunger > 100:
			hunger = 100
		
		print("Worker ate food. Hunger: ", hunger, " Food remaining: ", Resources.food)
	
	current_food_source = null
	if active_work != null:
		action = Action.WORK
	else:
		action = Action.IDLE
		_switch_to_idle()

func _process_rest(delta: float) -> void:
	if _has_arrived(rest_distance):
		stamina += 10
		if stamina >= max_stamina:
			stamina = max_stamina
			action = Action.WORK
			if active_work:
				target_position = active_work.position
			
	else:
		_move_toward(delta)

func _process_work(delta: float) -> void:
	if active_work == null:
		_find_work()
		if active_work == null:
			_switch_to_idle()
		return
	if _has_arrived(5):
		_do_work()
	else:
		_move_toward(delta)

func _process_idle(delta: float) -> void:

	if active_work == null:
		_find_work()
	
	if active_work != null:
		action = Action.WORK

func _do_work() -> void:
	if stamina <= 0:
		return
	if WorkQueue._do_work(active_work.cell, effort):
		active_work = null

	stamina -= effort
	

func _find_work() -> void:
	active_work = WorkQueue._claim_work(position)
	if active_work:
		if log:
			print("Found work:", active_work["type"])
		action = Action.WORK
		target_position = active_work.position
		print("setting target positiong to active ork position in _find_ork")

# --- helpers ---
func _switch_to_idle() -> void:
	action = Action.IDLE
	_start_idle()

func _switch_to_rest(delta) -> void:
	var cleric = CharacterRegistry._get_closest_cleric(position)
	if cleric:
		target_position = cleric
		action = Action.REST
		_process_rest(delta)
	else:
		# no cleric? just wander
		_switch_to_idle()
