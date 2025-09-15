extends Node

# SaveSystem - Handles saving and loading game state to/from JSON files

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
	
	print("Game saved successfully to: ", file_path)
	return true

# Load game state from a named file (for in-game loading)
func load_game(save_name: String) -> bool:
	var save_data = load_save_data(save_name)
	if save_data == null:
		return false
	
	_restore_game_state(save_data)
	print("Game loaded successfully from in-game")
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
	
	print("Save data loaded from: ", file_path)
	return json.data

# Restore game state from save data (call this when game scene is active)
func restore_game_state(save_data: Dictionary) -> bool:
	if save_data.is_empty():
		push_error("Save data is empty")
		return false
	
	_restore_game_state(save_data)
	print("Game state restored to current scene")
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
		"work_queue": {}
	}
	
	# Find all entities in the scene tree
	var root = get_tree().current_scene
	_collect_entities_recursive(root, game_state)
	
	# Collect plants from PlantManager
	_collect_plants(game_state)
	
	# Collect global state data
	_collect_global_data(game_state)
	
	return game_state

# Recursively collect entities from scene tree
func _collect_entities_recursive(node: Node, game_state: Dictionary):
	# Check if this node is an entity we want to save
	if node.has_method("serialize"):
		var entity_data = node.serialize()
		
		match entity_data.get("type", ""):
			"worker":
				game_state.workers.append(entity_data)
			"cleric":
				game_state.clerics.append(entity_data)
			"rat":
				game_state.rats.append(entity_data)
			"fox":
				game_state.foxes.append(entity_data)
			"plant":
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
		# Create the plant marker sprite
		var plant_marker = plant_icon_scene.instantiate()
		game_node.add_child(plant_marker)
		
		# Set marker position
		if plant_data.has("position"):
			plant_marker.position = Vector2(plant_data.position.x, plant_data.position.y)
		
		# Create the plant object
		var plant = Plant.new()
		plant.marker = plant_marker
		
		# Deserialize plant data
		if plant.has_method("deserialize"):
			plant.deserialize(plant_data)
		else:
			push_error("Plant entity missing deserialize method")
		
		# Update the sprite to match plant's health level
		_update_plant_sprite_for_load(plant)
		
		# Register the plant with the PlantManager
		PlantManager._register(plant)
	
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
		var entity_type = entity_data.get("type", "")
		
		if entity_type in ["worker", "cleric", "rat", "fox", "plant"]:
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

# Helper function to update plant sprite during loading
func _update_plant_sprite_for_load(plant: Plant) -> void:
	var mrkr = plant.marker
	
	# Set the sprite to the seedling texture
	var new_atlas := AtlasTexture.new()
	new_atlas.atlas = preload("res://sprites/Seedling.png")
	
	# Calculate health level and sprite region
	var health_level = int(plant.health / 25) + 1  # Every 25 health units = 1 sprite level
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
	print("Restoring global data...")
	
	# Restore PlayerActions data
	if save_data.has("player_actions") and PlayerActions != null and PlayerActions.has_method("deserialize"):
		print("Restoring PlayerActions")
		PlayerActions.deserialize(save_data.player_actions)
	
	# Restore Resources data
	if save_data.has("resources") and Resources != null and Resources.has_method("deserialize"):
		print("Restoring Resources")
		Resources.deserialize(save_data.resources)
	
	# Restore WorkQueue data (must be done after scene setup)
	if save_data.has("work_queue") and WorkQueue != null and WorkQueue.has_method("deserialize"):
		print("Restoring WorkQueue with ", save_data.work_queue.get("work_requests", []).size(), " requests")
		_restore_work_queue_with_markers(save_data.work_queue)
	else:
		print("WorkQueue restoration skipped - data available: ", save_data.has("work_queue"), " WorkQueue exists: ", WorkQueue != null)

# Special restoration for work queue that recreates markers
func _restore_work_queue_with_markers(work_queue_data: Dictionary) -> void:
	# Clear existing work requests
	WorkQueue._clear_all_work()
	
	# Get the terrain generator for marker creation
	var tree = get_tree()
	var main_node = tree.current_scene  # This is the Main node
	print("Main node: ", main_node)
	
	# Get the main scene manager to access current_scene
	var main_script = main_node
	if not main_script.has_method("load_scene"):
		push_error("Main node does not have expected scene management methods")
		return
	
	# Access the current game scene through the main script's current_scene variable
	var terrain_gen = null
	if "current_scene" in main_script:
		var game_scene = main_script.current_scene
		print("Game scene: ", game_scene)
		if game_scene != null and game_scene.has_method("map_to_local"):
			terrain_gen = game_scene
		else:
			# Try to find TileMapLayer child
			terrain_gen = game_scene.get_node("TileMapLayer") if game_scene != null else null
	
	if terrain_gen == null or not terrain_gen.has_method("map_to_local"):
		push_error("Could not find terrain generator for work queue restoration")
		return
	
	print("Found terrain_gen: ", terrain_gen)
	
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
				print("Reset work request status from '", request_data.status, "' to 'pending' for cell ", request.cell)
			if request_data.has("effort"):
				request.effort = request_data.effort
			if request_data.has("command_data"):
				request.command_data = request_data.command_data
			
			# Recreate marker for dig/plant work types
			if request.type in ["dig", "plant"]:
				var marker_scene = dig_icon_scene if request.type == "dig" else plant_icon_scene
				var marker = marker_scene.instantiate()
				terrain_gen.add_child(marker)
				
				# Use the same positioning logic as new work creation
				marker.position = terrain_gen.map_to_local(request.cell)
				
				# Update the request position to match the marker (in case of any rounding differences)
				request.position = marker.position
				
				# Update command data with new marker path
				request.command_data["marker_path"] = marker.get_path()
			
			# Reconstruct the callback
			request._reconstruct_callback()
			
			# Add to work queue using the same method as new work creation
			print("Adding restored work request: type=", request.type, " cell=", request.cell, " position=", request.position, " status=", request.status, " effort=", request.effort)
			WorkQueue._add_work(request)
