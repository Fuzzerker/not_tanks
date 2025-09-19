class_name WanderState
extends State

var character: WorkingCharacter
var wander_target: Vector2 = Vector2.ZERO
var wander_start: Vector2 = Vector2.ZERO

func _init(char: WorkingCharacter):
	character = char

func execute() -> void:
	if character.house == null:
		character.house = _find_house()
		
	if character.active_work != null:
		return
		
	_try_find_work()
	
	if character.active_work != null:
		return
	
	# Move toward wander target if we have one
	if wander_target != Vector2.ZERO:
		if not character._has_arrived(10):
			character._set_target_position(wander_target)
		else:
			_generate_wander_target()
	else:
		_generate_wander_target()

func on_enter() -> void:
	print("[%s] Entering Wander State" % character.character_name)
	wander_start = character.position

func on_exit() -> void:
	print("[%s] Exiting Wander State" % character.character_name)

func get_state_name() -> String:
	return "Wander"

func _generate_wander_target() -> void:
	#print("_generate_wander_target ")
	# Generate a random position within wander distance from the start position
	var wander_range = 50.0
	var random_offset = Vector2(
		randf_range(-wander_range, wander_range),
		randf_range(-wander_range, wander_range)
	)
	wander_target = wander_start + random_offset
	character._set_target_position(wander_target)

func _try_find_work() -> void:
	var work_request: WorkRequest = null
	if character.stamina <= 0:
		return
	if character.has_method("_try_find_work"):
		work_request = character._try_find_work()
	else:
		work_request = WorkQueue._claim_work(character.position, character.entity_type)
	
	if work_request != null:
		character.active_work = work_request
		character._set_target_position(work_request.position)
		print("[%s] Found work: %s at %s" % [
			character.character_name, 
			work_request.type, 
			work_request.position
		])

func _find_house():
	var my_house = BuildingManager._get_assigned_house(character.character_name)
	if my_house != null:
		return my_house
	return null
