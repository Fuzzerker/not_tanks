extends Resource

class_name Building

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

@export var building_type: String = ""
@export var position: Vector2
@export var construction_complete: bool = false
@export var occupied_cells: Array[Vector2i] = []
@export var entity_type: EntityTypes.EntityType
var marker: Sprite2D

# Serialization methods
func serialize() -> Dictionary:
	var cells_data = []
	for cell in occupied_cells:
		cells_data.append({"x": cell.x, "y": cell.y})
	
	return {
		"building_type": building_type,
		"position": {"x": position.x, "y": position.y},
		"construction_complete": construction_complete,
		"occupied_cells": cells_data,
		"entity_type": EntityTypes.type_to_string(entity_type),
		"marker_path": str(marker.get_path()) if marker != null else ""
	}

func deserialize(data: Dictionary) -> void:
	if data.has("building_type"):
		building_type = data.building_type
	if data.has("position"):
		position = Vector2(data.position.x, data.position.y)
	if data.has("construction_complete"):
		construction_complete = data.construction_complete
	if data.has("occupied_cells"):
		occupied_cells.clear()
		for cell_data in data.occupied_cells:
			occupied_cells.append(Vector2i(cell_data.x, cell_data.y))
	if data.has("entity_type"):
		entity_type = EntityTypes.string_to_type(data.entity_type)
	if data.has("marker_path"):
		var marker_path = data.marker_path
		if marker_path != "":
			# Marker will be restored by the save system
			pass

func _get_info() -> Dictionary:
	return {
		"building_type": building_type,
		"position": position,
		"construction_complete": construction_complete,
		"occupied_cells": occupied_cells.size()
	}
