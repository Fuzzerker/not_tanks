extends "res://scripts/entities/characters/working_character.gd"

class_name Farmer

var carried_agua: int = 0
var max_agua: int = 3


func _on_work_state_exit():
	#print("_on_work_state_exit ", last_work.type)
	if last_work != null and last_work.type == "agua":
		carried_agua -= 1
	if last_work != null and last_work.type == "collect_agua":
		carried_agua += 1
		
func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.FARMER


func _try_find_work() -> WorkRequest:
	var request: WorkRequest
	if active_work != null:
		return null
	if carried_agua == max_agua:
		request = WorkQueue._claim_work_of_type(position, "agua")
		if request == null:
			WorkQueue._claim_work_not_of_types(position, entity_type, ["collect_agua"])
	else:
		if carried_agua == 0:
			request = WorkQueue._claim_work_not_of_types(position, entity_type, ["agua"])
		else:
			request = WorkQueue._claim_work(position, entity_type)
	return request
	
