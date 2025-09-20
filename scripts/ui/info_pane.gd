extends PanelContainer

const EntityTypes = preload("res://scripts/globals/entity_types.gd")


var margin: float = .5

@export var game_tilemap: TileMapLayer = null

var vboxChild: VBoxContainer = null
var cur_gen = null

func _ready() -> void:
	vboxChild = get_child(0).get_child(0) as VBoxContainer

func _get_one_at_position():
	var mouse_pos = game_tilemap.get_global_mouse_position()
	
	for infoable in InformationRegistry.infoables:
		if _unsafe(infoable):
			continue
			
		var sprite_to_use: Sprite2D = null
		
		# Determine which sprite to use for collision detection
		if infoable.has_method("get") and infoable.get("marker") != null and is_instance_valid(infoable.marker):
			# Entities with markers (plants, buildings)
			sprite_to_use = infoable.marker
		else:
			# Direct sprite entities (characters, animals)
			sprite_to_use = infoable
			
		# Check if mouse is over this entity
		var global_rect: Rect2 = sprite_to_use.get_rect().abs()
		global_rect = sprite_to_use.get_global_transform() * global_rect
		var has_point: bool = global_rect.has_point(mouse_pos)
		
		if has_point:
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
	
	# Only update if we have a valid entity under the mouse with _get_info method
	if under_mouse != null and under_mouse.has_method("_get_info"):
		var info_data = under_mouse._get_info()
		if info_data != null and not info_data.is_empty():
			cur_gen = under_mouse
		else:
			cur_gen = null
	else:
		cur_gen = null
		
	if cur_gen != null:
		_generate_ui()
		
	
		

func _generate_ui() -> void:
	if cur_gen == null:
		return
		
	# Clear existing UI elements
	for existing: Node in vboxChild.get_children():
		existing.queue_free()
	
	var props: Dictionary = cur_gen._get_info()
	if props.is_empty():
		return

	# Add entity type header
	var entity_type = "Unknown"
	if cur_gen.has_method("get") and cur_gen.get("entity_type") != null:
		entity_type = EntityTypes.type_to_string(cur_gen.get("entity_type"))
	
	var header_label = Label.new()
	header_label.text = entity_type.capitalize()
	header_label.add_theme_font_size_override("font_size", 16)
	header_label.add_theme_color_override("font_color", Color.WHITE)
	vboxChild.add_child(header_label)

	# Add properties
	for key in props:
		var value = props[key]
		
		# Format the value for display
		var formatted_value = _format_value_for_display(value)
		
		var margin_container: MarginContainer = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_left", margin)
		margin_container.add_theme_constant_override("margin_right", margin)
		margin_container.add_theme_constant_override("margin_top", margin)
		margin_container.add_theme_constant_override("margin_bottom", margin)

		var hbox: HBoxContainer = HBoxContainer.new()
		
		var key_label: Label = Label.new()
		key_label.text = _format_key_name(key) + ":"
		key_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		key_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)

		var value_label: Label = Label.new()
		value_label.text = formatted_value
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		hbox.add_child(key_label)
		hbox.add_child(value_label)

		margin_container.add_child(hbox)
		vboxChild.add_child(margin_container)

func _format_value_for_display(value) -> String:
	if value is Vector2:
		return "(" + str(int(value.x)) + ", " + str(int(value.y)) + ")"
	elif value is Rect2:
		var rect = Rect2i(value)
		return "(" + str(rect.position.x) + ", " + str(rect.position.y) + ", " + str(rect.size.x) + ", " + str(rect.size.y) + ")"
	elif value is Color:
		return "R:%.2f G:%.2f B:%.2f A:%.2f" % [float(value.r), float(value.g), float(value.b), float(value.a)]
	elif value is bool:
		return "Yes" if value else "No"
	else:
		return str(value)

func _format_key_name(key: String) -> String:
	# Convert snake_case to Title Case
	return key.replace("_", " ").capitalize()
