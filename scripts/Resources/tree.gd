extends Plant

class_name Arbol


# Arbol-specific properties
var base_scale: float = 0.5
var max_scale: float = 2.0
var base_position: Vector2  # Store the original base position for upward scaling
var _self_setup = false


func _init(_position = null):
	if _position != null:
		position = _position
		_setup_self()
	
	
	
	
func populate_from(data:Dictionary):
	super(data)
	_setup_self()
	
func _setup_self():
	
	entity_type = EntityTypes.EntityType.ARBOL
	max_health = 10000
	health = 1
	agua = 1
	max_total_gro = 20000
	total_gro = 1
	PlantManager._register(self)
	
	var terrain_gen = WorkCallbackFactory._get_terrain_gen()
	marker = terrain_gen.tree_icon.instantiate()
	terrain_gen.add_child(marker)
	
	marker.position = position
	cell = terrain_gen.local_to_map(position)
	
	position = marker.position
	
	# Add to scene and register with plant manager
	terrain_gen.add_child(self)
	update_scale()
	PlantManager._register(self)
	

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
