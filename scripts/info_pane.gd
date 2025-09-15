extends PanelContainer


@export var orker_deets:Label
@export var cleric_deets:Label
@export var rat_deets:Label

var margin = .5

@export var game_tilemap: TileMapLayer = null

var vboxChild: VBoxContainer = null
var cur_gen = null;

func _ready():
	vboxChild = get_child(0).get_child(0) as VBoxContainer

var log_interval = 2.0
var time_accrual = 0.0

func _get_one_at_position():
	for infoable in InformationRegistry.infoables:
		var infoable_type = infoable.get("type")
		print(infoable_type)
		if _unsafe(infoable):
			continue
		
		var sprite_to_use: Sprite2D = null
		
		if infoable_type == "plant":
			sprite_to_use = infoable.marker
		else:
			sprite_to_use = infoable
		#print(infoable, " pos: ", infoable.position, " mouse_pos: ", global, " ", " hasPoint ", infoable.get_rect().has_point(global))

		var global_rect: Rect2 = sprite_to_use.get_rect().abs()  # ensure positive size
		global_rect = sprite_to_use.get_global_transform() * global_rect
		var has_point = global_rect.has_point(game_tilemap.get_global_mouse_position())
		
		
		var txt_str = str(infoable.get("type")," \ntm_global_mouse_pos: ", Vector2i(game_tilemap.get_global_mouse_position()), " \nglobal_rect: ", Rect2i(global_rect), "\nhas_point: ",has_point)
		if infoable_type == "plant":
			orker_deets.text =txt_str
		if infoable_type == "cleric":
			cleric_deets.text =txt_str
		if infoable_type == "rat":
			rat_deets.text =txt_str
		
		if  has_point:
			return infoable
	return null
	
func _unsafe(infoable) -> bool:
	var infoable_is_null = infoable == null
	var info_queued_for_delete = infoable.is_queued_for_deletion()
	var info_has_is_instance_valid = infoable.has_method("is_instance_valid")
	var instance_valid = true
	if info_has_is_instance_valid:
		instance_valid = infoable.is_instance_valid()
	
	var marker_marked_null = true
	var marker_marked_for_deletion = false
	
	if infoable is not Sprite2D:
		if infoable.marker != null:
			marker_marked_null = false
			marker_marked_for_deletion = infoable.marker.is_queued_for_deletion()
		
	
	if infoable_is_null or info_queued_for_delete or not instance_valid  or marker_marked_for_deletion:
		InformationRegistry.infoables.erase(infoable)
		return true
		
	return false
	

func _process(delta: float) -> void:
	var under_mouse = _get_one_at_position()
	var under_mouse_null = under_mouse == null
	var under_mouse_has__get_info = false
	var under_mouse__get_info_null = true
	if not under_mouse_null:
		under_mouse_has__get_info = under_mouse.has_method("_get_info")
	if not under_mouse_null and under_mouse_has__get_info:
		under_mouse__get_info_null = under_mouse._get_info() == null
	#print("under_mouse_null ", under_mouse_null, " under_mouse_has__get_info ", under_mouse_has__get_info, " under_mouse__get_info_null ", under_mouse__get_info_null)
	if not under_mouse_null and under_mouse_has__get_info and not under_mouse__get_info_null:
		cur_gen = under_mouse
	if cur_gen != null:
		_generate_ui()
		
	
		

func _generate_ui() -> void:
	
	if cur_gen == null:
		return
	for existing in vboxChild.get_children():
		existing.queue_free()
	
	var props = cur_gen._get_info()

	for key in props:
		var ra_val = props[key]
		if ra_val is Vector2:
			ra_val = Vector2i(ra_val)
		if ra_val is Rect2:
			ra_val = Rect2i(ra_val)
		
		var str_val = str(ra_val)
		var margin_container := MarginContainer.new()
		margin_container.add_theme_constant_override("margin_left", margin)
		margin_container.add_theme_constant_override("margin_right", margin)
		margin_container.add_theme_constant_override("margin_top", margin)
		margin_container.add_theme_constant_override("margin_bottom", margin)

		var hbox := HBoxContainer.new()
		
		var key_label := Label.new()
		key_label.text = str(key) + ":"
		key_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var value_label := Label.new()
		value_label.text = str_val
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		hbox.add_child(key_label)
		hbox.add_child(value_label)

		margin_container.add_child(hbox)
		vboxChild.add_child(margin_container)
