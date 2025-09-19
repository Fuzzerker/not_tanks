#class_name FindWorkState
#extends State
#
#var character: WorkingCharacter
#var search_timer: float = 0.0
#var search_interval: float = 1.0  # How often to search for work
#var max_search_attempts: int = 3
#var search_attempts: int = 0
#
#func _init(char: WorkingCharacter):
	#character = char
#
#func execute() -> void:
	#search_timer += character.get_process_delta_time()
	#
	#if search_timer >= search_interval:
		#_try_find_work()
		#search_timer = 0.0
		#search_attempts += 1
		#
		## If we've tried too many times, give up
		#if search_attempts >= max_search_attempts:
			#search_attempts = 0
#
#func on_enter() -> void:
	#print("[%s] Entering Find Work State" % character.character_name)
	#search_attempts = 0
	#search_timer = 0.0
#
#func on_exit() -> void:
	#print("[%s] Exiting Find Work State" % character.character_name)
#
#func get_state_name() -> String:
	#return "FindWork"
