class_name SpatialUtils

# Import required classes
const EntityTypes = preload("res://scripts/globals/entity_types.gd")

# Generic closest entity finder with optional filter function
static func find_closest_entity(
	entities: Array, 
	position: Vector2, 
	filter_func: Callable = Callable()
):
	var closest_entity = null
	var closest_dist: float = INF
	
	for entity in entities:
		if entity == null:
			continue
		if filter_func.is_valid() and not filter_func.call(entity):
			continue
		
		var dist: float = position.distance_squared_to(entity.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_entity = entity
	
	return closest_entity

# Specialized version for entities with type checking
static func find_closest_by_type(
	entities: Array, 
	position: Vector2, 
	entity_type: EntityTypes.EntityType
) -> Node:
	return find_closest_entity(entities, position, func(entity): 
		return entity.get("entity_type") == entity_type
	)

# Find closest entity that matches a property value
static func find_closest_by_property(
	entities: Array,
	position: Vector2,
	property_name: String,
	property_value
) -> Node:
	return find_closest_entity(entities, position, func(entity):
		return entity.get(property_name) == property_value
	)

# Find closest entity with custom condition and return distance too
static func find_closest_with_distance(
	entities: Array,
	position: Vector2,
	filter_func: Callable = Callable()
) -> Dictionary:
	var closest_entity = null
	var closest_dist: float = INF
	
	for entity in entities:
		if entity == null:
			continue
		if filter_func.is_valid() and not filter_func.call(entity):
			continue
		
		var dist: float = position.distance_squared_to(entity.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_entity = entity
	
	return {
		"entity": closest_entity,
		"distance": sqrt(closest_dist) if closest_entity else INF
	}
