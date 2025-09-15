extends TileMapLayer

var terrain_source = 0
var rogue_source = 0
var dirt_atlas = Vector2i(5,10)
var water_atlas = Vector2i(13,2)
var farmer_atlas = Vector2i(0,6)

var build_cleric = preload("res://preloads/build_cleric.tscn")
var cleric = preload("res://preloads/cleric.tscn")

var build_worker = preload("res://preloads/build_worker.tscn")
var worker = preload("res://preloads/worker.tscn")

var dig_icon = preload("res://preloads/dig_icon.tscn")
var plant_icon = preload("res://preloads/plant_icon.tscn")

var bcl: Sprite2D = null

@export var mous_pos_label:Label = null

func _ready() -> void:
	Resources.food = 100000
	for i in range(0,1):
		_place_worker()
	_set_terrain()

func _on_dig_pressed() -> void: 
	_cancel_action()
	PlayerActions.current_action = "dig" 
func _on_plant_pressed() -> void: 
	_cancel_action()
	PlayerActions.current_action = "plant"

var game_size = 50

func _set_terrain() -> void:
	for x in range(game_size * -1,game_size):
		for y in range(game_size * -1,game_size):
			set_cell(Vector2(x,y),0,Vector2(5,10))


# --- WORK HELPERS ------------------------------------------------------------

func _make_request(work_type: String, clicked_cell: Vector2i, marker: Sprite2D, on_complete: Callable) -> WorkRequest:
	var req := WorkRequest.new()
	req.type = work_type
	req.cell = clicked_cell
	req.position = marker.position
	req.effort = 100
	req.on_complete = on_complete
	return req

func _make_icon(scene: PackedScene) -> Sprite2D:
	var inst: Sprite2D = scene.instantiate()
	add_child(inst)
	var mouse_pos = get_local_mouse_position()
	var cell_pos = local_to_map(mouse_pos)
	inst.position = map_to_local(cell_pos)
	return inst


# --- ON COMPLETE BUILDERS ----------------------------------------------------

func _build_dig_on_completed(clicked_cell: Vector2i, marker: Sprite2D) -> Callable:
	return func():
		set_cell(clicked_cell, terrain_source, water_atlas)
		marker.queue_free()
		Resources.agua += 1

func _build_plant_on_completed(clicked_cell: Vector2i, marker: Sprite2D) -> Callable:
	return func():
		var old_atlas: AtlasTexture = marker.texture
		var new_atlas := AtlasTexture.new()
		new_atlas.atlas = preload("res://sprites/Seedling.png")
		new_atlas.region = Rect2(Vector2(13 * 16, 16), old_atlas.region.size)
		marker.texture = new_atlas

		var plant := Plant.new()
		plant.marker = marker
		plant.cell = clicked_cell
		plant.position = marker.position
		PlantManager._register(plant)


# --- TILE ACTIONS -------------------------------------_-----------------------

func _create_work_request(clicked_cell: Vector2i, marker: Sprite2D) -> void:
	match PlayerActions.current_action:
		"dig":
			WorkQueue._add_work(_make_request("dig", clicked_cell, marker, _build_dig_on_completed(clicked_cell, marker)))
		"plant":
			if Resources.seeds <= 0:
				return
			Resources.seeds -= 1
			WorkQueue._add_work(_make_request("plant", clicked_cell, marker, _build_plant_on_completed(clicked_cell, marker)))

func _create_work_icon() -> Sprite2D:
	match PlayerActions.current_action:
		"dig":
			return _make_icon(dig_icon)
		"plant":
			if Resources.seeds > 0:
				return _make_icon(plant_icon)
	return null

func _set_tile_action(clicked_cell: Vector2i) -> void:
	if WorkQueue._has_work(clicked_cell):
		return
	var marker = _create_work_icon()
	if marker:
		_create_work_request(clicked_cell, marker)


# --- CLERIC ------------------------------------------------------------------

func _cancel_action() -> void:
	PlayerActions.current_action = null
	if bcl != null and not bcl.is_queued_for_deletion():
		bcl.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _place_cleric() -> void:
	if Store._buy_cleric():
		var cl = cleric.instantiate()
		cl.position = get_local_mouse_position()
		PlayerActions.current_action = null
		add_child(cl)
	if bcl != null and not bcl.is_queued_for_deletion():
		bcl.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _place_worker() -> void:
	if Store._buy_worker():
		var cl = worker.instantiate()
		cl.position = get_local_mouse_position()
		if bcl != null:
			bcl.queue_free()
		PlayerActions.current_action = null
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		add_child(cl)

# --- INPUT HANDLING ----------------------------------------------------------

var clicked = false

func _tilemap_click() -> void:
	var clicked_cell = local_to_map(get_local_mouse_position())
	match PlayerActions.current_action:
		"dig", "plant":
			_set_tile_action(clicked_cell)
		"place_cleric":
			_place_cleric()
		"place_worker":
			_place_worker()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE:
		if Engine.time_scale != 0:
			Engine.time_scale = 0
		else:
			Engine.time_scale = 1
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

func _process(delta: float) -> void:
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
