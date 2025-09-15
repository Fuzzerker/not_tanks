extends Node

# Global entity type definitions
enum EntityType {
	CROP,
	ARBOL,
	CLERIC,
	WORKER,
	RAT,
	FOX
}

# Convert enum to string for display/serialization
static func type_to_string(entity_type: EntityType) -> String:
	match entity_type:
		EntityType.CROP:
			return "crop"
		EntityType.ARBOL:
			return "arbol"
		EntityType.CLERIC:
			return "cleric"
		EntityType.WORKER:
			return "worker"
		EntityType.RAT:
			return "rat"
		EntityType.FOX:
			return "fox"
		_:
			return "unknown"

# Convert string to enum for deserialization
static func string_to_type(type_string: String) -> EntityType:
	match type_string:
		"crop":
			return EntityType.CROP
		"arbol":
			return EntityType.ARBOL
		"cleric":
			return EntityType.CLERIC
		"worker":
			return EntityType.WORKER
		"rat":
			return EntityType.RAT
		"fox":
			return EntityType.FOX
		"plant":  # Legacy compatibility
			return EntityType.CROP
		_:
			push_error("Unknown entity type: " + type_string)
			return EntityType.CROP  # Default fallback
