extends Node

# SaveSystem - Handles saving and loading game state to/from JSON files

# Import required classes
const ArbolClass = preload("res://scripts/resources/tree.gd")
const WorkCallbackFactory = preload("res://scripts/globals/work_callback_factory.gd")
const Building = preload("res://scripts/resources/building.gd")
const EntityTypes = preload("res://scripts/globals/entity_types.gd")

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".json"

var savables: Array = []

func _ready():
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.open("user://").make_dir_recursive("saves")
		
func _register(savable):
	savables.push_back(savable)
	

# Save the current game state to a named file
func save_game(save_name: String) -> bool:
	if save_name.is_empty():
		push_error("Save name cannot be empty")
		return false
		
	var datas = []
	
	for savable in savables:
		if savable != null:
			datas.push_back(savable.get_info())
		
	var json_string = JSON.stringify(datas)
	
	var file_path = SAVE_DIR + save_name + SAVE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to create save file: " + file_path)
		return false
	
	file.store_string(json_string)
	file.close()
	
	return true

# Load save data from file without restoring to scene (for main menu loading)
func load_save_data(save_name: String) -> Array:
	if save_name.is_empty():
		push_error("Save name cannot be empty")
		return []
	savables = []
	var file_path = SAVE_DIR + save_name + SAVE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open save file: " + file_path)
		return []
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file JSON")
		return []
	
	return json.data

# Restore game state from save data (call this when game scene is active)
func restore_game_state(save_data: Array) -> bool:
	if save_data.is_empty():
		push_error("Save data is empty")
		return false
	
	TimeManager.flush()
	PlantManager.flush()
	BuildingManager.flush()
	WorkQueue.flush()
	
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

var entity_preloads = []

func _restore_game_state(save_data: Array):
	for item in save_data:
		var inst = null
		
		var entity_type = EntityTypes.type_to_string(item["entity_type"])
		if entity_type == "arbol":
			inst = Arbol.new()
		else: if entity_type == "crop":
			inst = Plant.new()
		else:
			var prel = load("res://preloads/"+entity_type+".tscn")
			inst = prel.instantiate()
		
		inst.populate_from(item)
		WorkCallbackFactory._get_terrain_gen().add_child(inst)
		print(entity_type)
	
	return
	
