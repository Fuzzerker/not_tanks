extends Node

# WorkCallbackFactory - Centralized factory for creating work request callbacks
# This eliminates duplication between WorkRequest and SaveSystem callback creation

class_name WorkCallbackFactory

# Create a callback for the given work request type and command data
static func create_callback(type: String, cell: Vector2i, command_data: Dictionary) -> Callable:
	match type:
		"dig":
			return _create_dig_callback(cell, command_data)
		"crop":
			return _create_plant_callback(cell, command_data)
		"harvest":
			return _create_harvest_callback(command_data)
		"agua":
			return _create_agua_callback(command_data)
		_:
			push_warning("Unknown work type: " + type)
			return Callable()

# Create dig callback from command data
static func _create_dig_callback(cell: Vector2i, command_data: Dictionary) -> Callable:
	var terrain_gen = _get_terrain_gen()
	if terrain_gen != null:
		return func():
			terrain_gen.set_cell(cell, 0, Vector2i(13, 2))  # water_atlas
			if command_data.has("marker_path"):
				var marker = terrain_gen.get_node_or_null(command_data.marker_path)
				if marker:
					marker.queue_free()
			Resources.agua += 1
	else:
		return Callable()

# Create plant callback from command data  
static func _create_plant_callback(cell: Vector2i, command_data: Dictionary) -> Callable:
	var terrain_gen = _get_terrain_gen()
	if terrain_gen != null:
		return func():
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
					PlantManager._register(plant)
	else:
		return Callable()

# Create harvest callback from command data
static func _create_harvest_callback(command_data: Dictionary) -> Callable:
	return func():
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
static func _create_agua_callback(command_data: Dictionary) -> Callable:
	return func():
		if command_data.has("plant_id"):
			# Find and water the plant
			for plant in PlantManager._plants:
				if plant.get_instance_id() == command_data.plant_id:
					plant.agua = 6
					break

# Helper to get terrain generator - shared logic between both systems
static func _get_terrain_gen():
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
