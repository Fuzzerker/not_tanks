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
		"foxes": []
	}
	
	# Find all entities in the scene tree
	var root = get_tree().current_scene
	_collect_entities_recursive(root, game_state)
	
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
	
	# Recursively check children
	for child in node.get_children():
		_collect_entities_recursive(child, game_state)

# Restore game state from save data
func _restore_game_state(save_data: Dictionary):
	# Clear existing entities first
	_clear_existing_entities()
	
	# Load entity preloads
	var worker_scene = preload("res://preloads/worker.tscn")
	var cleric_scene = preload("res://preloads/cleric.tscn")
	var rat_scene = preload("res://preloads/rat.tscn")
	var fox_scene = preload("res://preloads/fox.tscn")
	
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
		
		if entity_type in ["worker", "cleric", "rat", "fox"]:
			node.queue_free()
			return  # Don't process children of deleted nodes
	
	# Process children (in reverse to avoid index issues with deletions)
	var children = node.get_children()
	for i in range(children.size() - 1, -1, -1):
		_clear_entities_recursive(children[i])
