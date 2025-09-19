class_name JobCapabilities

# Import required classes
const EntityTypes = preload("res://scripts/globals/entity_types.gd")

# Define job capabilities for different character types
# This system allows flexible assignment of work types to character classes

enum JobType {
	DIG,
	PLANT, 
	HARVEST,
	AGUA,
	CHOP,
	COLLECT_AGUA,
	CONSTRUCTION
}

# Convert string work types to JobType enum
static func string_to_job_type(work_type: String) -> JobType:
	match work_type:
		"dig":
			return JobType.DIG
		"crop":
			return JobType.PLANT
		"harvest":
			return JobType.HARVEST
		"agua":
			return JobType.AGUA
		"chop":
			return JobType.CHOP
		"collect_agua":
			return JobType.COLLECT_AGUA
		"construction":
			return JobType.CONSTRUCTION
		_:
			push_warning("Unknown work type: " + work_type)
			return JobType.DIG  # Default fallback

# Convert JobType enum to string
static func job_type_to_string(job_type: JobType) -> String:
	match job_type:
		JobType.DIG:
			return "dig"
		JobType.PLANT:
			return "crop"
		JobType.HARVEST:
			return "harvest"
		JobType.AGUA:
			return "agua"
		JobType.CHOP:
			return "chop"
		JobType.COLLECT_AGUA:
			return "collect_agua"
		JobType.CONSTRUCTION:
			return "construction"
		_:
			return "dig"

# Define capabilities for each character type
static func get_character_capabilities(entity_type: EntityTypes.EntityType) -> Array[JobType]:
	match entity_type:
		EntityTypes.EntityType.WORKER:
			return [JobType.DIG, JobType.PLANT, JobType.CONSTRUCTION]  # Workers can dig, plant, and construct
		EntityTypes.EntityType.FARMER:
			return [JobType.PLANT, JobType.AGUA, JobType.COLLECT_AGUA, JobType.HARVEST]  # Farmers can plant, water, and collect agua
		EntityTypes.EntityType.CUTTER:
			return [JobType.CHOP]  # Cutters can only chop trees
		EntityTypes.EntityType.CLERIC:
			return []  # Clerics don't do work
		_:
			return []  # Default: no capabilities

# Check if a character type can perform a specific work type
static func can_do_work(entity_type: EntityTypes.EntityType, work_type: String) -> bool:
	var job_type = string_to_job_type(work_type)
	var capabilities = get_character_capabilities(entity_type)
	return job_type in capabilities

# Get all work types a character can perform as strings
static func get_work_types_for_character(entity_type: EntityTypes.EntityType) -> Array[String]:
	var capabilities = get_character_capabilities(entity_type)
	var work_types: Array[String] = []
	
	for job_type in capabilities:
		work_types.append(job_type_to_string(job_type))
	
	return work_types
