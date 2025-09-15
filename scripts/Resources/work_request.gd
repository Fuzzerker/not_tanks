extends Resource

class_name WorkRequest

# Import the shared callback factory
const WorkCallbackFactory = preload("res://scripts/globals/work_callback_factory.gd")

@export var type: String
@export var cell: Vector2i
@export var position: Vector2
@export var status: String = "pending"
@export var effort: int = 100
var on_complete: Callable = Callable()

# Command data for serialization (replaces callbacks)
@export var command_data: Dictionary = {}

# Serialize work request data for saving
func serialize() -> Dictionary:
	return {
		"type": type,
		"cell": {"x": cell.x, "y": cell.y},
		"position": SerializationUtils.serialize_vector2(position),
		"status": status,
		"effort": effort,
		"command_data": command_data
	}

# Deserialize work request data when loading
func deserialize(data: Dictionary) -> void:
	if data.has("type"):
		type = data.type
	if data.has("cell"):
		cell = Vector2i(data.cell.x, data.cell.y)
	if data.has("position"):
		position = SerializationUtils.deserialize_vector2(data.position)
	if data.has("status"):
		status = data.status
	if data.has("effort"):
		effort = data.effort
	if data.has("command_data"):
		command_data = data.command_data
	
	# Reconstruct the callback based on command data
	_reconstruct_callback()

# Reconstruct callback from command data using the shared factory
func _reconstruct_callback() -> void:
	on_complete = WorkCallbackFactory.create_callback(type, cell, command_data)
