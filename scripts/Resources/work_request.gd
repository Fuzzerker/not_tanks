extends Resource

class_name WorkRequest

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
		"position": {"x": position.x, "y": position.y},
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
		position = Vector2(data.position.x, data.position.y)
	if data.has("status"):
		status = data.status
	if data.has("effort"):
		effort = data.effort
	if data.has("command_data"):
		command_data = data.command_data
	
	# Reconstruct the callback based on command data
	_reconstruct_callback()

# Reconstruct callback from command data
func _reconstruct_callback() -> void:
	print("Reconstructing callback for type: ", type, " with command_data: ", command_data)
	match type:
		"dig":
			_create_dig_callback()
		"plant":
			_create_plant_callback()
		"harvest":
			_create_harvest_callback()
		"agua":
			_create_agua_callback()

# Create dig callback from command data
func _create_dig_callback() -> void:
	var terrain_gen = _get_terrain_gen()
	print("Dig callback - terrain_gen: ", terrain_gen, " has set_cell: ", terrain_gen != null and terrain_gen.has_method("set_cell"))
	if terrain_gen != null:
		on_complete = func():
			terrain_gen.set_cell(cell, 0, Vector2i(13, 2))  # water_atlas
			if command_data.has("marker_path"):
				var marker = terrain_gen.get_node_or_null(command_data.marker_path)
				if marker:
					marker.queue_free()
			Resources.agua += 1

# Create plant callback from command data  
func _create_plant_callback() -> void:
	var terrain_gen = _get_terrain_gen()
	print("Plant callback - terrain_gen: ", terrain_gen, " has get_node_or_null: ", terrain_gen != null and terrain_gen.has_method("get_node_or_null"))
	if terrain_gen != null:
		on_complete = func():
			if command_data.has("marker_path"):
				var marker = terrain_gen.get_node_or_null(command_data.marker_path)
				if marker:
					# Change marker sprite
					var old_atlas: AtlasTexture = marker.texture
					var new_atlas := AtlasTexture.new()
					new_atlas.atlas = preload("res://sprites/Seedling.png")
					new_atlas.region = Rect2(Vector2(13 * 16, 16), old_atlas.region.size)
					marker.texture = new_atlas
					
					# Create plant
					var plant := Plant.new()
					plant.marker = marker
					plant.cell = cell
					plant.position = marker.position
					plant.agua = 100
					PlantManager._register(plant)

# Create harvest callback from command data
func _create_harvest_callback() -> void:
	on_complete = func():
		print("harvested")
		Resources.food += 1
		Resources.seeds += randi_range(1, 3)
		if command_data.has("plant_id"):
			# Find and remove the plant
			for plant in PlantManager._plants:
				if plant.get_instance_id() == command_data.plant_id:
					if plant.marker:
						plant.marker.queue_free()
					plant.queue_free()
					PlantManager._plants.erase(plant)
					break

# Create agua callback from command data
func _create_agua_callback() -> void:
	on_complete = func():
		if command_data.has("plant_id"):
			# Find and water the plant
			for plant in PlantManager._plants:
				if plant.get_instance_id() == command_data.plant_id:
					plant.agua = 6
					break

# Helper to get terrain generator
func _get_terrain_gen():
	var scene_tree = Engine.get_main_loop()
	if not scene_tree or not scene_tree.current_scene:
		return null
	
	var main_node = scene_tree.current_scene  # This is the Main node
	
	# Access the current game scene through the main script's current_scene variable
	var terrain_gen = null
	if "current_scene" in main_node:
		var game_scene = main_node.current_scene
		if game_scene != null and game_scene.has_method("set_cell"):
			terrain_gen = game_scene
		else:
			# Try to find TileMapLayer child
			terrain_gen = game_scene.get_node("TileMapLayer") if game_scene != null else null
	
	return terrain_gen
