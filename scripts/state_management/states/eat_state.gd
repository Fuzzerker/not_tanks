class_name EatState
extends State

var character: WorkingCharacter
var food_source: Node2D = null
var eating_timer: float = 0.0
var eating_duration: float = 2.0  # Time to spend eating

func _init(char: WorkingCharacter):
	character = char

func execute() -> void:
	# Find food source if we don't have one
	if food_source == null:
		food_source = _find_food_source()
		if food_source == null:
			# No food available, exit eating state
			return
	
	# Move to food source
	var distance_to_food = character.global_position.distance_to(food_source.global_position)
	if distance_to_food > character.eating_distance:
		character.target_position = food_source.global_position
		return
	
	# We're at food source, eat
	eating_timer += character.get_process_delta_time()
	if eating_timer >= eating_duration:
		_consume_food()
		eating_timer = 0.0

func on_enter() -> void:
	print("[%s] Entering Eat State" % character.character_name)
	character._set_action(character.Action.EATING, "entering eat state")
	food_source = _find_food_source()

func on_exit() -> void:
	print("[%s] Exiting Eat State" % character.character_name)
	food_source = null
	eating_timer = 0.0

func get_state_name() -> String:
	return "Eat"

func _find_food_source() -> Node2D:
	# Working characters eat from stores/food sources
	if Resources.food > 0:
		var food_source: Node2D = Node2D.new()
		food_source.global_position = character.global_position  # For now, eat "in place"
		return food_source
	return null

func _consume_food() -> void:
	# Working characters consume food from resources
	if Resources.food > 0:
		Resources.food -= 1
		var hunger_gain = 30
		character.hunger += hunger_gain
		
		# Cap hunger at 100
		if character.hunger > 100:
			character.hunger = 100
		
		print("[%s] Ate food, hunger restored by %d (now %d)" % [
			character.character_name, 
			hunger_gain, 
			character.hunger
		])
		
		# Check if we should continue eating or stop
		if character.hunger > 70:  # Stop eating when well-fed
			food_source = null
