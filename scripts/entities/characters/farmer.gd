extends "res://scripts/entities/characters/working_character.gd"

# Farmer - Human character specialized in planting and watering
# Inherits all common working character functionality from WorkingCharacter

var carried_agua: int = 0  # Amount of agua the farmer is carrying

func _setup_character_type() -> void:
	entity_type = EntityTypes.EntityType.FARMER

func _find_work() -> void:
	# Simplified farmer job logic:
	# 1. Always do agua work if I have agua
	# 2. Do not claim new agua work if out of agua  
	# 3. If I do not have work and am out of agua, claim a collect_agua job
	
	if carried_agua > 0:
		# Has agua - look for plants to water
		active_work = WorkQueue._claim_specific_work(position, "agua", EntityTypes.EntityType.FARMER)
	
	if active_work == null and carried_agua == 0:
		# No agua - look for agua to collect first
		active_work = WorkQueue._claim_specific_work(position, "collect_agua", EntityTypes.EntityType.FARMER)
	
	if active_work == null:
		# Look for any other farmer work (planting, etc.)
		active_work = WorkQueue._claim_work(position, EntityTypes.EntityType.FARMER)
		
		# If we found agua work but have no agua, skip it and look for collect_agua instead
		if active_work != null and active_work.type == "agua" and carried_agua <= 0:
			# Release the agua work and look for collect_agua work
			active_work.status = "pending"  # Release it back
			active_work = WorkQueue._claim_specific_work(position, "collect_agua", EntityTypes.EntityType.FARMER)
	
	if active_work:
		_set_action(Action.WORK, "found work: " + active_work.type)
		target_position = active_work.position

# Override work completion to handle agua collection
func _do_work() -> void:
	if stamina <= 0:
		return
	
	# Handle different work types
	if active_work.type == "collect_agua":
		if WorkQueue._do_work(active_work.cell, effort):
			# Successfully collected agua - add to farmer's inventory
			carried_agua += 1
			active_work = null
	elif active_work.type == "agua":
		# Check if we have agua to give
		if carried_agua > 0:
			if WorkQueue._do_work(active_work.cell, effort):
				# Successfully watered plant - remove agua from inventory
				carried_agua -= 1
				active_work = null
		else:
			# Don't have agua - abandon this work and look for collection work
			active_work = null
	else:
		# Handle other work types normally
		if WorkQueue._do_work(active_work.cell, effort):
			active_work = null

	stamina -= effort
	_update_speed()  # Update speed when stamina decreases from work

# Override info display to show agua inventory
func _get_info() -> Dictionary:
	var info: Dictionary = super()
	info["carried_agua"] = carried_agua
	return info

# Override serialization to include agua inventory
func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	data["carried_agua"] = carried_agua
	return data

# Override deserialization to include agua inventory
func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("carried_agua"):
		carried_agua = data.carried_agua
