class_name SerializationUtils

# Serialize a Vector2 to a dictionary
static func serialize_vector2(vec: Vector2) -> Dictionary:
	return {"x": vec.x, "y": vec.y}

# Deserialize a Vector2 from a dictionary
static func deserialize_vector2(data: Dictionary) -> Vector2:
	return Vector2(data.x, data.y)

# Serialize basic entity data (position and class info)
static func serialize_entity_base(entity: Node) -> Dictionary:
	var data = {
		"position": serialize_vector2(entity.position)
	}
	
	# Add class name if the script has one
	var script = entity.get_script()
	if script and script.has_method("get_global_name"):
		var script_class_name = script.get_global_name()
		if script_class_name != "":
			data["class_name"] = script_class_name
	
	return data

# Deserialize entity position from data
static func deserialize_entity_position(entity: Node, data: Dictionary) -> void:
	if data.has("position"):
		entity.position = deserialize_vector2(data.position)

# Serialize common entity properties (position, target_position, etc.)
static func serialize_mover_data(mover: Node) -> Dictionary:
	var data = serialize_entity_base(mover)
	
	if mover.has_method("get") and mover.get("target_position") != null:
		data["target_position"] = serialize_vector2(mover.target_position)
	if mover.has_method("get") and mover.get("speed") != null:
		data["speed"] = mover.speed
	
	return data

# Deserialize common mover properties
static func deserialize_mover_data(mover: Node, data: Dictionary) -> void:
	deserialize_entity_position(mover, data)
	
	if data.has("target_position"):
		mover.target_position = deserialize_vector2(data.target_position)
	if data.has("speed"):
		mover.speed = data.speed

# Helper function to safely get nested dictionary values
static func safe_get_nested(data: Dictionary, keys: Array, default_value = null):
	var current = data
	for key in keys:
		if not current.has(key):
			return default_value
		current = current[key]
	return current

# Helper function to safely set nested dictionary values
static func safe_set_nested(data: Dictionary, keys: Array, value) -> void:
	var current = data
	for i in range(keys.size() - 1):
		var key = keys[i]
		if not current.has(key):
			current[key] = {}
		current = current[key]
	current[keys[-1]] = value
