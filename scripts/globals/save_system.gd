extends Node

# SaveSystem - Handles saving and loading game state to/from JSON files

# Import required classes
const ArbolClass = preload("res://scripts/resources/tree.gd")
const WorkCallbackFactory = preload("res://scripts/globals/work_callback_factory.gd")

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".json"

func _ready():
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.open("user://").make_dir_recursive("saves")

# Save the current game state to a named file
func save_game(save_name: String) -> bool:
	if save_name.is_empty():
		push_error("Save name cannot be empty")
		return false
	
	var save_data = _collect_game_state()
	var json_string = JSON.stringify(save_data)
	
	var file_path = SAVE_DIR + save_name + SAVE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to create save file: " + file_path)
		return false
	
	file.store_string(json_string)
	file.close()
	
	return true

# Load game state from a named file (for in-game loading)
func load_game(save_name: String) -> bool:
	var save_data = load_save_data(save_name)
	if save_data == null:
		return false
	
	_restore_game_state(save_data)
	return true

# Load save data from file without restoring to scene (for main menu loading)
func load_save_data(save_name: String) -> Dictionary:
	if save_name.is_empty():
		push_error("Save name cannot be empty")
		return {}
	
	var file_path = SAVE_DIR + save_name + SAVE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open save file: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file JSON")
		return {}
	
	return json.data

# Restore game state from save data (call this when game scene is active)
func restore_game_state(save_data: Dictionary) -> bool:
	if save_data.is_empty():
		push_error("Save data is empty")
		return false
	
	_restore_game_state(save_data)
	return true

# Get list of available save files
func get_save_list() -> Array:
	var saves = []
	var dir = DirAccess.open(SAVE_DIR)
	
	if dir == null:
		return saves
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(SAVE_EXTENSION):
			var save_name = file_name.get_basename()
			saves.append(save_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return saves

# Delete a save file
func delete_save(save_name: String) -> bool:
	var dir = DirAccess.open(SAVE_DIR)
	
	if dir == null:
		return false
	
	return dir.remove(save_name + SAVE_EXTENSION) == OK

# Collect all entities and their states
func _collect_game_state() -> Dictionary:
	var game_state = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"workers": [],
		"clerics": [],
		"rats": [],
		"foxes": [],
		"plants": [],
		"player_actions": {},
		"resources": {},
		"work_queue": {},
		"terrain": {}
	}
	
	# Find all entities in the scene tree
	var root = get_tree().current_scene
	_collect_entities_recursive(root, game_state)
	
	# Collect plants from PlantManager
	_collect_plants(game_state)
	
	# Collect global state data
	_collect_global_data(game_state)
	
	# Collect terrain data
	_collect_terrain_data(game_state)
	
	return game_state

# Recursively collect entities from scene tree
func _collect_entities_recursive(node: Node, game_state: Dictionary):
	# Check if this node is an entity we want to save
	if node.has_method("serialize"):
		var entity_data = node.serialize()
		
		match entity_data.get("entity_type", ""):
			"worker":
				game_state.workers.append(entity_data)
			"cleric":
				game_state.clerics.append(entity_data)
			"rat":
				game_state.rats.append(entity_data)
			"fox":
				game_state.foxes.append(entity_data)
			"crop", "arbol":
				game_state.plants.append(entity_data)
	
	# Recursively check children
	for child in node.get_children():
		_collect_entities_recursive(child, game_state)

# Restore game state from save data
func _restore_game_state(save_data: Dictionary):
	# Clear existing entities first
	_clear_existing_entities()
	
	# Clear existing plants from PlantManager
	_clear_plants()
	
	# Load entity preloads
	var worker_scene = preload("res://preloads/worker.tscn")
	var cleric_scene = preload("res://preloads/cleric.tscn")
	var rat_scene = preload("res://preloads/rat.tscn")
	var fox_scene = preload("res://preloads/fox.tscn")
	var plant_icon_scene = preload("res://preloads/plant_icon.tscn")
	var tree_icon_scene = preload("res://preloads/tree_icon.tscn")
	
	# Get the main game node (where entities should be spawned)
	var game_node = get_tree().current_scene
	
	# Restore workers
	for worker_data in save_data.get("workers", []):
		var worker = worker_scene.instantiate()
		game_node.add_child(worker)  # Add to scene first
		if worker.has_method("deserialize"):
			worker.deserialize(worker_data)  # Then deserialize (this will call _ready)
		else:
			push_error("Worker entity missing deserialize method")
	
	# Restore clerics
	for cleric_data in save_data.get("clerics", []):
		var cleric = cleric_scene.instantiate()
		game_node.add_child(cleric)  # Add to scene first
		if cleric.has_method("deserialize"):
			cleric.deserialize(cleric_data)  # Then deserialize
		else:
			push_error("Cleric entity missing deserialize method")
	
	# Restore rats
	for rat_data in save_data.get("rats", []):
		var rat = rat_scene.instantiate()
		game_node.add_child(rat)  # Add to scene first
		if rat.has_method("deserialize"):
			rat.deserialize(rat_data)  # Then deserialize
		else:
			push_error("Rat entity missing deserialize method")
	
	# Restore foxes
	for fox_data in save_data.get("foxes", []):
		var fox = fox_scene.instantiate()
		game_node.add_child(fox)  # Add to scene first
		if fox.has_method("deserialize"):
			fox.deserialize(fox_data)  # Then deserialize
		else:
			push_error("Fox entity missing deserialize method")
	
	# Restore plants
	for plant_data in save_data.get("plants", []):
		# Determine plant type and create appropriate object
		var plant_type: String = plant_data.get("entity_type", "crop")  # Default to crop for legacy saves
		var plant = null
		
		if plant_type == "arbol":
			# Create arbol with proper sprite
			var arbol_marker = tree_icon_scene.instantiate()
			game_node.add_child(arbol_marker)
			
			# Set marker position
			if plant_data.has("position"):
				arbol_marker.position = Vector2(plant_data.position.x, plant_data.position.y)
			
			# Set arbol texture to use same sprite as when created
			var new_atlas := AtlasTexture.new()
			new_atlas.atlas = preload("res://sprites/misc_tiles.png")
			var atlas_loc = Vector2(3, 24)
			var rect_size = Vector2(1,2)
			new_atlas.region = Rect2(atlas_loc * 32, rect_size * 32)
			arbol_marker.texture = new_atlas
			
			# Create arbol instance
			plant = ArbolClass.new()
			plant.marker = arbol_marker
		else:
			# Create crop with seedling sprite
			var plant_marker = plant_icon_scene.instantiate()
			game_node.add_child(plant_marker)
			
			# Set marker position
			if plant_data.has("position"):
				plant_marker.position = Vector2(plant_data.position.x, plant_data.position.y)
			
			# Create crop instance
			plant = Plant.new()
			plant.marker = plant_marker
		
		# Deserialize plant data
		if plant.has_method("deserialize"):
			plant.deserialize(plant_data)
		else:
			push_error("Plant entity missing deserialize method")
		
		# Update the sprite to match plant's health level and type
		if plant_type == "arbol" and plant.has_method("update_scale"):
			plant.update_scale()  # Use scaling for arbols
		else:
			_update_plant_sprite_for_load(plant)  # Use sprite changes for crops
		
		# Register the plant with the PlantManager
		PlantManager._register(plant)
	
	# Restore terrain data
	_restore_terrain_data(save_data)
	
	# Restore global state data
	_restore_global_data(save_data)

# Clear all existing entities from the game
func _clear_existing_entities():
	var root = get_tree().current_scene
	_clear_entities_recursive(root)

# Recursively clear entities from scene tree
func _clear_entities_recursive(node: Node):
	if node == null:
		return
	# Check if this node is an entity we want to clear
	if node.has_method("serialize"):
		var entity_data = node.serialize()
		var entity_type = entity_data.get("entity_type", "")
		
		if entity_type in ["worker", "cleric", "rat", "fox", "crop", "arbol"]:
			node.queue_free()
			return  # Don't process children of deleted nodes
	
	# Process children (in reverse to avoid index issues with deletions)
	var children = node.get_children()
	for i in range(children.size() - 1, -1, -1):
		_clear_entities_recursive(children[i])

# Collect plants from PlantManager
func _collect_plants(game_state: Dictionary) -> void:
	if PlantManager != null and PlantManager.has_method("_get_all_plants"):
		var plants = PlantManager._get_all_plants()
		for plant in plants:
			if plant.has_method("serialize"):
				game_state.plants.append(plant.serialize())
	else:
		# Fallback: access plants array directly if method doesn't exist
		if PlantManager != null and "_plants" in PlantManager:
			for plant in PlantManager._plants:
				if plant.has_method("serialize"):
					game_state.plants.append(plant.serialize())

# Collect global state data from singletons
func _collect_global_data(game_state: Dictionary) -> void:
	# Collect PlayerActions data
	if PlayerActions != null and PlayerActions.has_method("serialize"):
		game_state.player_actions = PlayerActions.serialize()
	
	# Collect Resources data
	if Resources != null and Resources.has_method("serialize"):
		game_state.resources = Resources.serialize()
	
	# Collect WorkQueue data
	if WorkQueue != null and WorkQueue.has_method("serialize"):
		game_state.work_queue = WorkQueue.serialize()

# Collect terrain data from the TileMapLayer
func _collect_terrain_data(game_state: Dictionary) -> void:
	
	# Find the terrain generator (TileMapLayer) in the scene
	var terrain_gen: TileMapLayer = _find_terrain_generator()
	if terrain_gen != null and terrain_gen.has_method("serialize_tiles"):
		game_state.terrain = terrain_gen.serialize_tiles()


# Helper function to find the terrain generator in the scene
func _find_terrain_generator() -> TileMapLayer:
	var root: Node = get_tree().current_scene
	if root != null:
		# Look for the Main scene first
		if root.has_method("load_scene"):  # This is the Main scene
			# Access the current game scene through main's current_scene
			if "current_scene" in root and root.current_scene != null:
				var game_scene: Node = root.current_scene
				# Try to find TileMapLayer in the game scene
				var terrain_gen: Node = game_scene.get_node_or_null("TileMapLayer")
				if terrain_gen is TileMapLayer:
					return terrain_gen
		else:
			# We're directly in the game scene, look for TileMapLayer
			var terrain_gen: Node = root.get_node_or_null("TileMapLayer")
			if terrain_gen is TileMapLayer:
				return terrain_gen
	
	return null

# Restore terrain data from save data
func _restore_terrain_data(save_data: Dictionary) -> void:
	if not save_data.has("terrain"):
		return
	
	
	# Find the terrain generator
	var terrain_gen: TileMapLayer = _find_terrain_generator()
	if terrain_gen != null and terrain_gen.has_method("deserialize_tiles"):
		terrain_gen.deserialize_tiles(save_data.terrain)


# Helper function to update plant sprite during loading
func _update_plant_sprite_for_load(plant: Plant) -> void:
	var mrkr = plant.marker
	
	# Set the sprite to the seedling texture
	var new_atlas := AtlasTexture.new()
	new_atlas.atlas = preload("res://sprites/Seedling.png")
	
	# Calculate health level and sprite region
	var health_level = int(plant.health / 25.0) + 1  # Every 25 health units = 1 sprite level
	var atlas_y_offset = health_level * 16  # 16 pixels per level
	
	# Set the appropriate region based on health
	new_atlas.region = Rect2(Vector2(13 * 16, 16 + atlas_y_offset), Vector2(16, 16))
	mrkr.texture = new_atlas

# Clear all plants from PlantManager
func _clear_plants() -> void:
	if PlantManager != null and PlantManager.has_method("_clear_all_plants"):
		PlantManager._clear_all_plants()
	else:
		# Fallback: clear plants array directly if method doesn't exist
		if PlantManager != null and "_plants" in PlantManager:
			# First queue_free all plant markers
			for plant in PlantManager._plants:
				if plant.marker != null:
					plant.marker.queue_free()
				plant.queue_free()
			# Clear the array
			PlantManager._plants.clear()

# Restore global state data from save data
func _restore_global_data(save_data: Dictionary) -> void:
	
	# Restore PlayerActions data
	if save_data.has("player_actions") and PlayerActions != null and PlayerActions.has_method("deserialize"):
		PlayerActions.deserialize(save_data.player_actions)
	
	# Restore Resources data
	if save_data.has("resources") and Resources != null and Resources.has_method("deserialize"):
		Resources.deserialize(save_data.resources)
	
	# Restore WorkQueue data (must be done after scene setup)
	if save_data.has("work_queue") and WorkQueue != null and WorkQueue.has_method("deserialize"):
		_restore_work_queue_with_markers(save_data.work_queue)


# Special restoration for work queue that recreates markers
func _restore_work_queue_with_markers(work_queue_data: Dictionary) -> void:
	# Clear existing work requests
	WorkQueue._clear_all_work()
	
	# Get the terrain generator for marker creation
	var tree = get_tree()
	var main_node = tree.current_scene  # This is the Main node
	
	# Get the main scene manager to access current_scene
	var main_script = main_node
	if not main_script.has_method("load_scene"):
		push_error("Main node does not have expected scene management methods")
		return
	
	# Access the current game scene through the main script's current_scene variable
	var terrain_gen = null
	if "current_scene" in main_script:
		var game_scene = main_script.current_scene
		if game_scene != null and game_scene.has_method("map_to_local"):
			terrain_gen = game_scene
		else:
			# Try to find TileMapLayer child
			terrain_gen = game_scene.get_node("TileMapLayer") if game_scene != null else null
	
	if terrain_gen == null or not terrain_gen.has_method("map_to_local"):
		push_error("Could not find terrain generator for work queue restoration")
		return
	
	
	# Load preloaded scenes for markers
	var dig_icon_scene = preload("res://preloads/dig_icon.tscn")
	var plant_icon_scene = preload("res://preloads/plant_icon.tscn")
	
	# Restore work requests
	if work_queue_data.has("work_requests"):
		for request_data in work_queue_data.work_requests:
			var request = WorkRequest.new()
			
			# Deserialize basic data first
			if request_data.has("type"):
				request.type = request_data.type
			if request_data.has("cell"):
				request.cell = Vector2i(request_data.cell.x, request_data.cell.y)
			if request_data.has("position"):
				request.position = Vector2(request_data.position.x, request_data.position.y)
			if request_data.has("status"):
				# Reset all work to "pending" status since worker assignments are lost during load
				request.status = "pending"
			if request_data.has("effort"):
				request.effort = request_data.effort
			if request_data.has("command_data"):
				request.command_data = request_data.command_data
			
			# Recreate marker for dig/plant work types
			if request.type in ["dig", "crop"]:
				var marker_scene = dig_icon_scene if request.type == "dig" else plant_icon_scene
				var marker = marker_scene.instantiate()
				terrain_gen.add_child(marker)
				
				# Use the same positioning logic as new work creation
				marker.position = terrain_gen.map_to_local(request.cell)
				
				# Update the request position to match the marker (in case of any rounding differences)
				request.position = marker.position
				
				# Update command data with new marker path
				request.command_data["marker_path"] = marker.get_path()
			
			# Reconstruct the callback using the shared factory
			request.on_complete = WorkCallbackFactory.create_callback(request.type, request.cell, request.command_data)
			
			# Add to work queue using the same method as new work creation
			WorkQueue._add_work(request)
