class_name WorkState
extends State

var character: WorkingCharacter
var work_start_time: float = 0.0

func _init(char: WorkingCharacter, str):
	character = char


func execute() -> void:
	# Check if we have work assigned
	if character.active_work == null:
		return
	
	# Check if we're at the work location
	if not character._has_arrived(10):
		# Move to work location
		character.target_position = character.active_work.position
		character._move_toward()
		return
	
	# We're at the work location, execute the work
	_execute_work()

func on_enter() -> void:
	print("[%s] Entering Work State" % character.character_name)
	work_start_time = Time.get_time_dict_from_system()["second"]

func on_exit() -> void:
	if character.has_method("_on_work_state_exit"):
		character._on_work_state_exit()
	if character.active_work != null and character.active_work.effort > 0:
		print("abandoning ")
		WorkQueue._abandon_work(character.active_work.cell)
		character.active_work = null
	print("[%s] Exiting Work State" % character.character_name)

func get_state_name() -> String:
	return "Work"

func _execute_work() -> void:
	if character.stamina <= 0:
		return
	
	# Execute work based on type
	var work_type = character.active_work.type
	_do_work()
	
	
	#match work_type:
		#"dig":
			#success = work_executor.execute_dig_work(character.active_work, character.effort)
		#"chop":
			#success = work_executor.execute_chop_work(character.active_work, character.effort)
		#"plant":
			#success = work_executor.execute_plant_work(character.active_work, character.effort)
		#"agua":
			#success = work_executor.execute_water_work(character.active_work, character.effort)
		#_:
			#push_warning("Unknown work type: " + work_type)

		
func _do_work():

	character.active_work.effort -= character.effort
	character.stamina -= character.effort
	if character.stamina <= 0:
		print("break")
	#print(character.active_work.effort, " effort ", character.effort, " stam ", character.stamina)
	if character.active_work.effort <= 0:
		character.terrain_gen._complete_work(character.active_work)
		character.last_work = character.active_work
		character.active_work = null
		print(character.last_work, character.active_work )
