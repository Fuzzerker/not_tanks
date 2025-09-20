extends TileMapLayer
class_name TerrainGen
# Import required classes
var EntityTypes = preload("res://scripts/globals/entity_types.gd")

# Track dug tiles that have agua available for collection
var agua_tiles: Array[Vector2i] = []

var terrain_source = 0
var rogue_source = 0
var dirt_atlas = Vector2i(5,10)
var water_atlas = Vector2i(13,2)
var farmer_atlas = Vector2i(0,6)

var build_cleric = preload("res://preloads/build_cleric.tscn")
var cleric = preload("res://preloads/cleric.tscn")

var build_worker = preload("res://preloads/build_worker.tscn")
var worker = preload("res://preloads/worker.tscn")

var build_farmer = preload("res://preloads/build_farmer.tscn")
var farmer = preload("res://preloads/farmer.tscn")

var build_cutter = preload("res://preloads/build_cutter.tscn")
var cutter = preload("res://preloads/cutter.tscn")

var build_fighter = preload("res://preloads/build_fighter.tscn")
var fighter = preload("res://preloads/fighter.tscn")

var rat = preload("res://preloads/rat.tscn")
var fox = preload("res://preloads/fox.tscn")

var dig_icon = preload("res://preloads/dig_icon.tscn")
var plant_icon = preload("res://preloads/plant_icon.tscn")
var tree_icon = preload("res://preloads/tree_icon.tscn")
var chop_icon = preload("res://preloads/chop_icon.tscn")
var agua_icon = preload("res://preloads/agua_icon.tscn")

var construction_icon = preload("res://preloads/construction_icon.tscn")

var bcl: Sprite2D = null
var gameplay_menu: Control = null
var previous_time_scale: float = 1.0
var is_paused: bool = false

@export var mous_pos_label:Label = null

func _ready() -> void:
	Resources.food = 100000
	_set_terrain()
	
	# Get reference to the gameplay menu and connect its load signal
	gameplay_menu = get_node("../CanvasLayer/GameplayMenu")
	if gameplay_menu:
		gameplay_menu.load_game.connect(_on_load_game_from_menu)

# Load a game save directly without UI dependencies
func load_game_save(save_name: String) -> bool:
	if save_name.is_empty():
		push_error("Save name cannot be empty")
		return false
	
	# Load save data and restore to current scene (which should be the game scene)
	var save_data = SaveSystem.load_save_data(save_name)
	if save_data.is_empty():
		push_error("Failed to load save data for: " + save_name)
		return false
	
	return SaveSystem.restore_game_state(save_data)

# Handle load game signal from gameplay menu - delegate to main scene manager
func _on_load_game_from_menu(save_name: String) -> void:
	# Get the main scene manager and tell it to load the game
	var main_scene: Node = get_tree().current_scene
	if main_scene and main_scene.has_method("_on_load_game"):
		main_scene._on_load_game(save_name)
	else:
		push_error("Could not find main scene manager to handle load game request")

func _complete_work(request: WorkRequest):
	print("completing ", request.type)
	WorkQueue._complete_work(request)
	WorkCallbackFactory.create_callback(request.type, request.cell, request.marker).call()


func _on_dig_pressed() -> void: 
	_cancel_action()
	PlayerActions.current_action = "dig" 
func _on_plant_pressed() -> void: 
	_cancel_action()
	PlayerActions.current_action = "crop"
	
func _on_chop_pressed() -> void:
	_cancel_action()
	PlayerActions.current_action = "chop"
	
func _on_tree_pressed() -> void:
	_cancel_action()
	PlayerActions.current_action = "arbol"

var game_size = 50

func _set_terrain() -> void:
	for x in range(game_size * -1,game_size):
		for y in range(game_size * -1,game_size):
			set_cell(Vector2(x,y),0,Vector2(5,10))


# --- WORK HELPERS ------------------------------------------------------------



# --- ON COMPLETE BUILDERS ----------------------------------------------------



# --- TILE ACTIONS -------------------------------------_-----------------------

func _set_tile_action(clicked_cell: Vector2i, marker_path: String) -> void:
	# Set tile action in a 3x3 radius around the clicked cell
	
			
	# Skip if this cell already has work
	if WorkQueue._has_work(clicked_cell):
		return
	
	WorkRequest.new(PlayerActions.current_action, clicked_cell, map_to_local(clicked_cell) , marker_path )
			

func _set_chop_action(clicked_cell: Vector2i) -> void:
	# Find arbol at this position first
	var arbol = _find_arbol_at_position(map_to_local(clicked_cell))
	if arbol == null:
		return  # No arbol to chop

	var arbol_cell = arbol.cell
	# Check if there's already work at this specific cell (for other job types)
	if WorkQueue._has_work(arbol_cell):
		return
	
	WorkRequest.new("chop", arbol_cell, map_to_local(arbol_cell), "res://preloads/chop_icon.tscn" )
	
	
	

func _find_arbol_at_position(world_pos: Vector2) -> Plant:
	# Use PlantManager to find arbol at this position
	var closest_plant = PlantManager._get_closest_plant(world_pos)
	if closest_plant and closest_plant.entity_type == EntityTypes.EntityType.ARBOL:
		# Check if it's close enough (within same cell)
		var distance = world_pos.distance_to(closest_plant.position)
		if distance < 32:  # Within one tile
			return closest_plant
	return null


# --- CLERIC ------------------------------------------------------------------

func _cancel_action() -> void:
	PlayerActions.current_action = ""
	if bcl != null and not bcl.is_queued_for_deletion():
		bcl.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _place_cleric() -> void:
	if Store._buy_cleric():
		var cl = cleric.instantiate()
		cl.position = get_local_mouse_position()
		PlayerActions.current_action = ""
		add_child(cl)
	if bcl != null and not bcl.is_queued_for_deletion():
		bcl.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _place_worker() -> void:
	for i in range(0,1):
		if Store._buy_worker():
			var cl = worker.instantiate()
			cl.position = get_local_mouse_position()
			if bcl != null:
				bcl.queue_free()
			PlayerActions.current_action = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			add_child(cl)

func _place_farmer() -> void:
	for i in range(0,1):
		if Store._buy_farmer():
			var cl = farmer.instantiate()
			cl.position = get_local_mouse_position()
			if bcl != null:
				bcl.queue_free()
			PlayerActions.current_action = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			add_child(cl)

func _place_cutter() -> void:
	for i in range(0,1):
		if Store._buy_cutter():
			var cl = cutter.instantiate()
			cl.position = get_local_mouse_position()
			if bcl != null:
				bcl.queue_free()
			PlayerActions.current_action = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			add_child(cl)

func _place_fighter() -> void:
	for i in range(0,1):
		if Store._buy_fighter():
			var cl = fighter.instantiate()
			cl.position = get_local_mouse_position()
			if bcl != null:
				bcl.queue_free()
			PlayerActions.current_action = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			add_child(cl)

func _place_rat() -> void:
	var rat_instance = rat.instantiate()
	rat_instance.position = get_local_mouse_position()
	PlayerActions.current_action = ""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	add_child(rat_instance)

func _place_fox() -> void:
	var fox_instance = fox.instantiate()
	fox_instance.position = get_local_mouse_position()
	PlayerActions.current_action = ""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	add_child(fox_instance)

func _place_arbol() -> void:
	print("nah")

# --- BUILDING PLACEMENT ------------------------------------------------------

# Calculate which tiles are occupied by a building sprite using BuildingManager dimensions


# Create building work (construction jobs) instead of placing building directly
func _create_building_work(building_type: String) -> void:
	# Snap to grid like plants do
	var clicked_cell = local_to_map(get_local_mouse_position())
	var snapped_position = map_to_local(clicked_cell)
	
	var config = BuildingManager._get_building_config(building_type)
	
	var occupied_cells = SpatialUtils.calculate_occupied_cells(clicked_cell, config.get("dimensions"))
	
	# Check if any cells are already occupied by work or other buildings
	for cell in occupied_cells:
		if WorkQueue._has_work(cell):
			return  # Can't place building here
	
	
	var entity_type: EntityTypes.EntityType
	# Set entity type based on building type
	match building_type:
		"smithy":
			entity_type = EntityTypes.EntityType.SMITHY
		"house":
			entity_type = EntityTypes.EntityType.HOUSE
	# Register building and create construction work
	Building.new(building_type, clicked_cell, snapped_position,false,entity_type,"")

	_create_building_construction_work(building_type, occupied_cells)
	
	# Clear the action
	PlayerActions.current_action = ""

# Create construction work for a building (called by BuildingManager)
func _create_building_construction_work(building_type: String, occupied_cells: Array) -> void:
	var config = BuildingManager._get_building_config(building_type)
	
	# Create construction work for each tile the building occupies
	for cell in occupied_cells:
		# Check if there's already work at this location
		if WorkQueue._has_work(cell):
			continue
			
		WorkRequest.new("construction", cell, map_to_local(cell), "res://preloads/construction_icon.tscn", config.construction_effort )

# Create construction icon for a cell
func _create_construction_icon(cell: Vector2i) -> Sprite2D:
	var construction_icon_scene = preload("res://preloads/construction_icon.tscn")
	var icon = construction_icon_scene.instantiate()
	add_child(icon)
	icon.position = map_to_local(cell)
	return icon


var clicked = false

func _tilemap_click() -> void:
	var clicked_cell = local_to_map(get_local_mouse_position())
	match PlayerActions.current_action:
		"dig":
			_set_tile_action(clicked_cell, "res://preloads/dig_icon.tscn")
		"crop":
			_set_tile_action(clicked_cell, "res://preloads/plant_icon.tscn")
		"chop":
			_set_chop_action(clicked_cell)
		"arbol":
			_place_arbol()
		"build_smithy":
			_create_building_work("smithy")
		"build_house":
			_create_building_work("house")
		"place_cleric":
			_place_cleric()
		"place_worker":
			_place_worker()
		"place_farmer":
			_place_farmer()
		"place_cutter":
			_place_cutter()
		"place_fighter":
			_place_fighter()
		"place_rat":
			_place_rat()
		"place_fox":
			_place_fox()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE:
		if Engine.time_scale != 0:
			Engine.time_scale = 0
		else:
			Engine.time_scale = 1
	
	# Handle escape key to toggle pause menu
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		_toggle_pause_menu()
		return
	
	# Don't process other inputs if paused
	if is_paused:
		return
		
	if event is InputEventMouseMotion and clicked:
		_tilemap_click()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		clicked = event.is_pressed()
		if clicked:
			_tilemap_click()

# --- Time Buttons -----------------------------------------------------

func _on_speed_up_pressed() -> void:
	if Engine.time_scale == 50:
		return
	if Engine.time_scale < 1:
		Engine.time_scale += .25
	else: if Engine.time_scale == 1:
		Engine.time_scale = 3
	else: if Engine.time_scale == 3:
		Engine.time_scale = 5
	else: if Engine.time_scale == 5:
		Engine.time_scale = 10
	else: if Engine.time_scale == 10:
		Engine.time_scale = 50
	
	
	
func _on_speed_don_pressed() -> void:
	if Engine.time_scale <= 1:
		Engine.time_scale -= .25
	else: if Engine.time_scale == 3:
		Engine.time_scale = 1
	else: if Engine.time_scale == 5:
		Engine.time_scale = 3
	else: if Engine.time_scale == 10:
		Engine.time_scale = 5
	else: if Engine.time_scale == 50:
		Engine.time_scale = 10
		
	
	
func _on_pause_pressed() -> void:
	Engine.time_scale = 0

# --- BUILD CLERIC BUTTON -----------------------------------------------------

func _process(_delta: float) -> void:

	if bcl:
		bcl.position = get_global_mouse_position()
	mous_pos_label.text = str(get_global_mouse_position())

func _on_build_cleric_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bcl = build_cleric.instantiate()
	get_parent().add_child(bcl)
	PlayerActions.current_action = "place_cleric"
	
func _on_build_worker_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bcl = build_worker.instantiate()
	get_parent().add_child(bcl)
	PlayerActions.current_action = "place_worker"

func _on_build_farmer_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bcl = build_farmer.instantiate()
	get_parent().add_child(bcl)
	PlayerActions.current_action = "place_farmer"

func _on_build_cutter_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bcl = build_cutter.instantiate()
	get_parent().add_child(bcl)
	PlayerActions.current_action = "place_cutter"

func _on_build_fighter_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bcl = build_fighter.instantiate()
	get_parent().add_child(bcl)
	PlayerActions.current_action = "place_fighter"

func _on_build_smithy_pressed() -> void:
	PlayerActions.current_action = "place_smithy"

func _on_build_house_pressed() -> void:
	PlayerActions.current_action = "place_house"

func _on_build_smithy_work_pressed() -> void:
	PlayerActions.current_action = "build_smithy"

func _on_build_house_work_pressed() -> void:
	PlayerActions.current_action = "build_house"

func _on_spawn_rat_pressed() -> void:
	_cancel_action()
	PlayerActions.current_action = "place_rat"

func _on_spawn_fox_pressed() -> void:
	_cancel_action()
	PlayerActions.current_action = "place_fox"

# --- PAUSE MENU FUNCTIONALITY ------------------------------------------------

func _toggle_pause_menu() -> void:
	if is_paused:
		_resume_game()
	else:
		_pause_game()

func _pause_game() -> void:
	if not is_paused:
		previous_time_scale = Engine.time_scale
		Engine.time_scale = 0
		is_paused = true
		if gameplay_menu:
			gameplay_menu.show_menu()

func _resume_game() -> void:
	if is_paused:
		Engine.time_scale = previous_time_scale
		is_paused = false
		if gameplay_menu:
			gameplay_menu.hide_menu()

# --- GAMEPLAY MENU SIGNAL HANDLERS -------------------------------------------

func _on_resume_game() -> void:
	_resume_game()

func _on_quit_game() -> void:
	get_tree().quit()

# --- TILE DATA SERIALIZATION -------------------------------------------------

# Serialize tile data for saving
func serialize_tiles() -> Dictionary:
	var tile_data: Dictionary = {}
	
	# Get the used rect to only save tiles that have been set
	var used_rect: Rect2i = get_used_rect()
	
	# Only save if there are tiles to save
	if used_rect.size.x > 0 and used_rect.size.y > 0:
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
				var cell_pos: Vector2i = Vector2i(x, y)
				var source_id: int = get_cell_source_id(cell_pos)
				var atlas_coords: Vector2i = get_cell_atlas_coords(cell_pos)
				
				# Only save non-default tiles or if they have been explicitly set
				if source_id != -1:
					var cell_key: String = str(x) + "," + str(y)
					tile_data[cell_key] = {
						"source_id": source_id,
						"atlas_coords": {"x": atlas_coords.x, "y": atlas_coords.y}
					}
	
	return {
		"type": "terrain",
		"game_size": game_size,
		"tiles": tile_data
	}

# Deserialize and restore tile data
func deserialize_tiles(data: Dictionary) -> void:
	if not data.has("tiles"):
		return
	
	
	# Clear existing tiles first
	clear()
	
	# Restore game size if saved
	if data.has("game_size"):
		game_size = data.game_size
	
	# Restore each saved tile
	for cell_key: String in data.tiles:
		var coords: PackedStringArray = cell_key.split(",")
		if coords.size() == 2:
			var x: int = coords[0].to_int()
			var y: int = coords[1].to_int()
			var cell_pos: Vector2i = Vector2i(x, y)
			
			var tile_info: Dictionary = data.tiles[cell_key]
			var source_id: int = tile_info.source_id
			var atlas_coords: Vector2i = Vector2i(tile_info.atlas_coords.x, tile_info.atlas_coords.y)
			
			set_cell(cell_pos, source_id, atlas_coords)
	
