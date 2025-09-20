extends Node

# WorkCallbackFactory - Centralized factory for creating work request callbacks
# This eliminates duplication between WorkRequest and SaveSystem callback creation

class_name WorkCallbackFactory



# Create a callback for the given work request type and command data
static func create_callback(type: String, cell: Vector2i, marker: Sprite2D) -> Callable:
	match type:
		"dig":
			return _create_dig_callback(cell, marker)
		"crop":
			return _create_plant_callback(cell, marker)
		"harvest":
			return _create_harvest_callback(cell)
		"agua":
			return _create_agua_callback(cell, marker)
		"chop":
			return _create_chop_callback(cell, marker)
		"collect_agua":
			return _create_collect_agua_callback(cell)
		"construction":
			return _create_construction_callback(cell, marker)
		_:
			push_warning("Unknown work type: " + type)
			return Callable()

# Create dig callback from command data
static func _create_dig_callback(cell: Vector2i, marker: Sprite2D) -> Callable:
	var terrain_gen = _get_terrain_gen()
	return func():
		terrain_gen.set_cell(cell, 0, Vector2i(13, 2))  # water_atlas
		marker.queue_free()
		WorkRequest.new("collect_agua", cell, marker.position)



# Create plant callback from command data  
static func _create_plant_callback(cell: Vector2i, marker: Sprite2D) -> Callable:
	var terrain_gen = _get_terrain_gen()
	if terrain_gen != null:
		return func():
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
static func _create_harvest_callback(cell) -> Callable:
	return func():
		Resources.food += 1
		Resources.seeds += randi_range(1, 3)
		for plant in PlantManager._plants:
			if plant.cell == cell:
				if plant.marker:
					plant.marker.queue_free()
				PlantManager._plants.erase(plant)
				plant.queue_free()
				
				break

# Create agua callback from command data
static func _create_agua_callback(cell, marker) -> Callable:
	return func():
		for plant in PlantManager._plants:
			if plant.cell == cell:
				marker.queue_free()
				plant.agua += 60
				plant.agua_request_generated = false
				break
				
		# Note: The farmer's agua inventory is handled in the farmer's _do_work() override

# Create chop callback from command data
static func _create_chop_callback(cell, marker) -> Callable:
	return func():

			# Find and damage the arbol
		for plant in PlantManager._plants:
			if plant == null || plant.is_queued_for_deletion():
				continue
			if plant.cell == cell:
				plant.health -= 25  # Each chop does 25 damage
				
				# Update arbol scale to show shrinking
				if plant.has_method("update_scale"):
					plant.update_scale()
				
				if plant.health <= 0:
					plant.marker.queue_free()
					PlantManager._plants.erase(plant)
					plant.queue_free()
					marker.queue_free()
				else:
					# Tree still has health - the current job is complete, but we keep the marker
					# and create another chop request using the same marker
					WorkRequest.new("chop", plant.cell, plant.position, "res://preloads/chop_icon.tscn")
					
				break

# Create collect_agua callback from command data
static func _create_collect_agua_callback(cell) -> Callable:
	return func():
		var terrain_gen = _get_terrain_gen()
		if terrain_gen != null:
			# Remove agua from global resources and revert tile to dirt
			if Resources.agua > 0:
				Resources.agua -= 1
			terrain_gen.set_cell(cell, 0, terrain_gen.dirt_atlas)
			terrain_gen.agua_tiles.erase(cell)
			
				
				# Give agua to the farmer who completed this work
				# Note: We need to find the farmer and give them the agua
				# This will be handled by the farmer's work completion logic

# Create construction callback from command data
static func _create_construction_callback(cell, marker) -> Callable:
	return func():
		
			# Find the building and handle construction completion
		for building in BuildingManager.buildings:
			if building.occupied_cells.has(cell):
				# Call the building manager's completion function
				BuildingManager._complete_construction_work(building, cell)
				marker.queue_free()
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
			terrain_gen = game_scene.get_node("TileMapLayer") as TerrainGen if game_scene != null else null
	
	return terrain_gen
