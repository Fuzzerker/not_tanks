extends Plant

class_name Arbol


# Arbol-specific properties
var base_scale: float = 0.5
var max_scale: float = 2.0
var base_position: Vector2  # Store the original base position for upward scaling



func _init():
	# Arbol-specific initialization
	entity_type = EntityTypes.EntityType.ARBOL
	max_health = 200
	health = 1
	agua = 0  # Arbols don't need water
	max_total_gro = 200
	total_gro = 1
	PlantManager._register(self)

# Override to provide arbol-specific info
func _get_info() -> Dictionary:
	var info: Dictionary = super._get_info()
	info["base_scale"] = base_scale
	info["max_scale"] = max_scale
	info["current_scale"] = _calculate_scale()
	info["base_position"] = base_position
	return info

# Calculate scale based on health
func _calculate_scale() -> float:
	var health_ratio: float = float(health) / float(max_health)
	return base_scale + (max_scale - base_scale) * health_ratio

# Update arbol scale based on health
func update_scale() -> void:
	if marker != null:
		# Store base position on first call
		if base_position == Vector2.ZERO:
			base_position = marker.position
		
		var new_scale: float = _calculate_scale()
		
		# Calculate how much the sprite should move upward
		# When scaling up, we want the bottom of the sprite to stay in place
		var sprite_height: float = 16.0  # Default sprite height
		if marker.texture != null:
			sprite_height = float(marker.texture.get_height())
		var scale_diff: float = new_scale - base_scale
		var y_offset: float = -(sprite_height * scale_diff) * 0.5  # Move up by half the height difference
		
		# Apply scale and position adjustment
		marker.scale = Vector2(new_scale, new_scale)
		marker.position = Vector2(base_position.x, base_position.y + y_offset)

# Override serialize to include arbol-specific data
func serialize() -> Dictionary:
	var data: Dictionary = super.serialize()
	data["base_scale"] = base_scale
	data["max_scale"] = max_scale
	data["base_position"] = {"x": base_position.x, "y": base_position.y}
	return data

# Override deserialize to handle arbol-specific data
func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("base_scale"):
		base_scale = data.base_scale
	if data.has("max_scale"):
		max_scale = data.max_scale
	if data.has("base_position"):
		base_position = Vector2(data.base_position.x, data.base_position.y)
	
	# Update scale after deserialization
	update_scale()
