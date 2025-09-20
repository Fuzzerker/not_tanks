extends Node

# Global entity type definitions
enum EntityType {
	CROP,
	ARBOL,
	CLERIC,
	WORKER,
	FARMER,
	CUTTER,
	RAT,
	FOX,
	SMITHY,
	HOUSE,
	WORKREQUEST,
	SMITH,
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
		EntityType.FARMER:
			return "farmer"
		EntityType.CUTTER:
			return "cutter"
		EntityType.RAT:
			return "rat"
		EntityType.FOX:
			return "fox"
		EntityType.SMITHY:
			return "smithy"
		EntityType.HOUSE:
			return "house"
		EntityType.WORKREQUEST:
			return "workrequest"
		EntityType.SMITH:
			return "smith"
		_:
			return "unknown"

# Convert string to enum for deserialization
static func string_to_type(type_str: String) -> EntityType:
	match type_str:
		"crop":
			return EntityType.CROP
		"arbol":
			return EntityType.ARBOL
		"cleric":
			return EntityType.CLERIC
		"worker":
			return EntityType.WORKER
		"farmer":
			return EntityType.FARMER
		"cutter":
			return EntityType.CUTTER
		"rat":
			return EntityType.RAT
		"fox":
			return EntityType.FOX
		"smithy":
			return EntityType.SMITHY
		"house":
			return EntityType.HOUSE
		"plant":  # Legacy compatibility
			return EntityType.CROP
		"workrequest":
			return EntityType.WORKREQUEST
		"smith":
			return EntityType.SMITH
		_:
			push_error("Unknown entity type: " + type_str)
			return EntityType.CROP  # Default fallback
