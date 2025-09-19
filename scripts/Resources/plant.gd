extends Node

class_name Plant

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

@export var marker: Sprite2D
@export var cell: Vector2i
@export var position: Vector2

var health: int = 1
var max_health: int = 1000
var agua: int = 0
var agua_request_generated = false
var entity_type: EntityTypes.EntityType = EntityTypes.EntityType.CROP
var max_total_gro: int = 1000
var total_gro: int = 1
func _get_info() -> Dictionary:
	
	return {
		"health": health,
		"agua": agua,
		"cell":cell,
		"total_gro":total_gro,
		"max_total_gro":max_total_gro,
		"position":position,
		"entity_type": EntityTypes.type_to_string(entity_type)
	}

# Serialize plant data for saving
func serialize() -> Dictionary:
	return {
		"entity_type": EntityTypes.type_to_string(entity_type),
		"health": health,
		"max_health": max_health,
		"agua": agua,
		"max_total_gro": max_total_gro,
		"total_gro": total_gro,
		"cell": {"x": cell.x, "y": cell.y},
		"position": SerializationUtils.serialize_vector2(position)
	}

# Deserialize plant data when loading
func deserialize(data: Dictionary) -> void:
	if data.has("health"):
		health = data.health
	if data.has("max_health"):
		max_health = data.max_health
	if data.has("agua"):
		agua = data.agua
	if data.has("max_total_gro"):
		max_total_gro = data.max_total_gro
	if data.has("total_gro"):
		total_gro = data.total_gro
	if data.has("cell"):
		cell = Vector2i(data.cell.x, data.cell.y)
	if data.has("position"):
		position = SerializationUtils.deserialize_vector2(data.position)
	if data.has("entity_type"):
		entity_type = EntityTypes.string_to_type(data.entity_type)
	elif data.has("type"):  # Legacy compatibility
		entity_type = EntityTypes.string_to_type(data.type)
