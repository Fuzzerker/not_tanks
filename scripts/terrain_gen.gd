extends TileMapLayer

var terrain_source = 0
var rogue_source = 0
var dirt_atlas = Vector2i(5,10)
var water_atlas = Vector2i(13,2)
var farmer_atlas = Vector2i(0,6)

var build_cleric = preload("res://preloads/build_cleric.tscn")
var cleric = preload("res://preloads/cleric.tscn")

var dig_icon = preload("res://preloads/dig_icon.tscn")

func _ready() -> void:
	_set_terrain()



	

func _set_terrain():
	for x in range(-50,50):
		for y in range(-50,50):
			set_cell(Vector2(x,y),0,Vector2(5,10))


func _on_dig_pressed() -> void:
	PlayerActions.current_action = "dig" # Replace with function body.
	
	
func _build_on_completed(clicked_cell, marker):
	var on_completed = func():
		set_cell(clicked_cell, terrain_source, water_atlas )
		marker.queue_free()	
		Resources.agua += 1
	
	return on_completed	
	
func _create_work_request(clicked_cell, marker):
	if PlayerActions.current_action == "dig":
		var request = {
			"type": "dig",
			"cell": clicked_cell,
			"position": get_local_mouse_position(),
			"status": "pending",
			"effort": 100,
			"on_complete": _build_on_completed(clicked_cell, marker)
		}
		WorkQueue._add_work(request)
		
		
		
func _create_work_icon():
	if PlayerActions.current_action == "dig":
		var inst = dig_icon.instantiate()
		add_child(inst)
		var mouse_pos = get_local_mouse_position()
		var cell_pos = local_to_map(mouse_pos)
		inst.position = map_to_local(cell_pos)
		return inst
	
var bcl = null	
	
func _place_cleric():
	var cl = cleric.instantiate()
	cl.position = get_local_mouse_position()
	bcl.queue_free()
	PlayerActions.current_action = null
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	add_child(cl)
	
func _set_tile_action(clicked_cell):
	if WorkQueue._has_work(clicked_cell):
		return
	var marker = _create_work_icon()
	_create_work_request(clicked_cell, marker)

func _tilemap_click():
	print("click ")
	var local_mouse_pos = get_local_mouse_position()              
	var clicked_cell = local_to_map(local_mouse_pos)
	if PlayerActions.current_action == "dig":
		_set_tile_action(clicked_cell)
	if PlayerActions.current_action == "place_cleric":
		_place_cleric()
	
	
	
var clicked = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and clicked:
		_tilemap_click()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
		clicked = true
		_tilemap_click()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT && !event.is_pressed():
		clicked = false




func _process(delta: float) -> void:
	if bcl != null:
		bcl.position = get_global_mouse_position()

func _on_build_cleric_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bcl = build_cleric.instantiate()
	get_parent().add_child(bcl)
	PlayerActions.current_action = "place_cleric"
