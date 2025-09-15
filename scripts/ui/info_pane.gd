extends PanelContainer


@export var orker_deets:Label
@export var cleric_deets:Label
@export var rat_deets:Label

var margin: float = .5

@export var game_tilemap: TileMapLayer = null

var vboxChild: VBoxContainer = null
var cur_gen = null

func _ready() -> void:
	Resources.seeds = 1000
	vboxChild = get_child(0).get_child(0) as VBoxContainer

var log_interval: float = 2.0
var time_accrual: float = 0.0

func _get_one_at_position():
	for infoable in InformationRegistry.infoables:

		if _unsafe(infoable):
			continue
		var infoable_type = infoable.get("type")
		
		var sprite_to_use: Sprite2D = null
		
		if infoable_type == "plant":
			# Additional safety check for marker access
			if infoable.has_method("get") and infoable.get("marker") != null and is_instance_valid(infoable.marker):
				sprite_to_use = infoable.marker
			else:
				continue  # Skip this infoable if marker is invalid
		else:
			sprite_to_use = infoable
		#print(infoable, " pos: ", infoable.position, " mouse_pos: ", global, " ", " hasPoint ", infoable.get_rect().has_point(global))

		var global_rect: Rect2 = sprite_to_use.get_rect().abs()  # ensure positive size
		global_rect = sprite_to_use.get_global_transform() * global_rect
		var has_point: bool = global_rect.has_point(game_tilemap.get_global_mouse_position())
		
		
		var txt_str: String = str(infoable.get("type")," \ntm_global_mouse_pos: ", Vector2i(game_tilemap.get_global_mouse_position()), " \nglobal_rect: ", Rect2i(global_rect), "\nhas_point: ",has_point)
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
	var infoable_is_null: bool = infoable == null
	if infoable_is_null:
		InformationRegistry.infoables.erase(infoable)
		return true
	
	var info_queued_for_delete: bool = infoable.is_queued_for_deletion()
	var info_has_is_instance_valid: bool = infoable.has_method("is_instance_valid")
	var instance_valid: bool = true
	if info_has_is_instance_valid:
		instance_valid = infoable.is_instance_valid()
	
	var _marker_marked_null: bool = true
	var marker_marked_for_deletion: bool = false
	var marker_invalid: bool = false
	
	if infoable is not Sprite2D:
		if infoable.has_method("get") and infoable.get("marker") != null:
			var marker = infoable.marker
			_marker_marked_null = false
			marker_marked_for_deletion = marker.is_queued_for_deletion()
			# Check if marker is a valid instance
			marker_invalid = not is_instance_valid(marker)
		
	
	if info_queued_for_delete or not instance_valid or marker_marked_for_deletion or marker_invalid:
		InformationRegistry.infoables.erase(infoable)
		return true
		
	return false
	

func _process(_delta: float) -> void:
	var under_mouse = _get_one_at_position()
	var under_mouse_null: bool = under_mouse == null
	var under_mouse_has__get_info: bool = false
	var under_mouse__get_info_null: bool = true
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
	for existing: Node in vboxChild.get_children():
		existing.queue_free()
	
	var props: Dictionary = cur_gen._get_info()

	for key in props:
		var ra_val = props[key]
		if ra_val is Vector2:
			ra_val = Vector2i(ra_val)
		if ra_val is Rect2:
			ra_val = Rect2i(ra_val)
		
		var str_val: String = str(ra_val)
		var margin_container: MarginContainer = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_left", margin)
		margin_container.add_theme_constant_override("margin_right", margin)
		margin_container.add_theme_constant_override("margin_top", margin)
		margin_container.add_theme_constant_override("margin_bottom", margin)

		var hbox: HBoxContainer = HBoxContainer.new()
		
		var key_label: Label = Label.new()
		key_label.text = str(key) + ":"
		key_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var value_label: Label = Label.new()
		value_label.text = str_val
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		hbox.add_child(key_label)
		hbox.add_child(value_label)

		margin_container.add_child(hbox)
		vboxChild.add_child(margin_container)
