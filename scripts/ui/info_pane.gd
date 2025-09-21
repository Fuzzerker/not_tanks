extends PanelContainer

const EntityTypes = preload("res://scripts/globals/entity_types.gd")


var margin: float = .5

@export var game_tilemap: TileMapLayer = null

var vboxChild: VBoxContainer = null
var cur_gen = null

# Properties to ignore in UI display (default Godot properties)
var ui_props_to_ignore = [
	"props_to_ignore",
	"state_machine",
	"house",
	"time_accumulator",
	"entity_scene",
	"active_work"
]

func _ready() -> void:
	# Use VBoxContainer2 (child 1) instead of VBoxContainer (child 0) to avoid conflicts
	vboxChild = get_child(0).get_child(0).get_child(0) as VBoxContainer
	# Set reasonable size constraints for the panel
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	custom_minimum_size.x = 200  # Minimum width to prevent it from being too narrow
	
	# Configure the HBoxContainer 
	var hbox = get_child(0) as HBoxContainer
	
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
	
var under_mouse:Savable = null
func _process(_delta: float) -> void:
	var ne_under_mouse = _get_one_at_position() as Savable
	if ne_under_mouse != null:
		under_mouse = ne_under_mouse
	# Only update if we have a valid entity under the mouse with get_ui_info method
	if under_mouse != null:
		var info_data = under_mouse.get_ui_info()
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
	
	var props: Dictionary = cur_gen.get_ui_info()
	if props.is_empty():
		return
		
	# Apply additional UI filtering (though get_ui_info should already filter most defaults)
	var filtered_props: Dictionary = {}
	for key in props:
		if not ui_props_to_ignore.has(key):
			filtered_props[key] = props[key]
	
	if filtered_props.is_empty():
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

	# Organize properties by category
	var categorized_props = _categorize_properties(filtered_props)
	
	# Display properties by category
	for category in categorized_props:
		var category_props = categorized_props[category]
		
		# Add category header
		if category != "General":
			_add_category_header(category)
		
		# Add properties in this category
		for key in category_props:
			var value = category_props[key]
			_add_property_row(key, value)

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
	elif value is float:
		# Format floats to 2 decimal places
		return "%.2f" % value
	elif value is int:
		# Format large numbers with commas for readability
		var str_value = str(value)
		var formatted = ""
		var count = 0
		for i in range(str_value.length() - 1, -1, -1):
			if count > 0 and count % 3 == 0:
				formatted = "," + formatted
			formatted = str_value[i] + formatted
			count += 1
		return formatted
	else:
		return str(value)

func _format_key_name(key: String) -> String:
	# Convert snake_case to Title Case
	return key.replace("_", " ").capitalize()

func _categorize_properties(props: Dictionary) -> Dictionary:
	var categories = {
		"Health & Stats": [],
		"Movement & Position": [],
		"Work & Behavior": [],
		"Resources": [],
		"General": []
	}
	
	# Define property categories
	var health_stats = ["health", "max_health", "hunger", "stamina", "max_stamina", "base_speed", "min_speed"]
	var movement_position = ["position", "velocity", "direction", "speed", "eating_distance", "custom_wander_start"]
	var work_behavior = ["job", "work_type", "state", "current_task", "hungry_interval", "hunger_threshold"]
	var resources = ["resources", "inventory", "items", "money", "food"]
	
	var categorized = {}
	
	for category in categories:
		categorized[category] = {}
	
	for key in props:
		var value = props[key]
		var categorized_key = false
		
		# Check each category
		if health_stats.has(key):
			categorized["Health & Stats"][key] = value
			categorized_key = true
		elif movement_position.has(key):
			categorized["Movement & Position"][key] = value
			categorized_key = true
		elif work_behavior.has(key):
			categorized["Work & Behavior"][key] = value
			categorized_key = true
		elif resources.has(key):
			categorized["Resources"][key] = value
			categorized_key = true
		
		if not categorized_key:
			categorized["General"][key] = value
	
	# Remove empty categories
	var final_categories = {}
	for category in categorized:
		if not categorized[category].is_empty():
			final_categories[category] = categorized[category]
	
	return final_categories

func _add_category_header(category_name: String) -> void:
	var separator = HSeparator.new()
	separator.add_theme_color_override("color", Color.GRAY)
	vboxChild.add_child(separator)
	
	var category_label = Label.new()
	category_label.text = category_name
	category_label.add_theme_font_size_override("font_size", 12)
	category_label.add_theme_color_override("font_color", Color.CYAN)
	category_label.add_theme_constant_override("margin_top", 8)
	category_label.add_theme_constant_override("margin_bottom", 4)
	vboxChild.add_child(category_label)

func _add_property_row(key: String, value) -> void:
	# Format the value for display
	var formatted_value = _format_value_for_display(value)
	
	var margin_container: MarginContainer = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 4)
	margin_container.add_theme_constant_override("margin_right", 4)
	margin_container.add_theme_constant_override("margin_top", 2)
	margin_container.add_theme_constant_override("margin_bottom", 2)

	var hbox: HBoxContainer = HBoxContainer.new()
	
	var key_label: Label = Label.new()
	key_label.text = _format_key_name(key) + ":"
	key_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	key_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	key_label.add_theme_font_size_override("font_size", 11)
	key_label.custom_minimum_size.x = 100  # Fixed width for consistency

	var value_label: Label = Label.new()
	value_label.text = formatted_value
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value_label.add_theme_font_size_override("font_size", 11)
	
	# Color code certain value types
	if value is int and (key.contains("health") or key.contains("hunger") or key.contains("stamina")):
		# Health-related values - green for good, red for low
		if key.contains("max_") or value >= 80:
			value_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		elif value <= 20:
			value_label.add_theme_color_override("font_color", Color.RED)
		elif value <= 50:
			value_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			value_label.add_theme_color_override("font_color", Color.WHITE)
	elif value is bool:
		# Boolean values - green for true, red for false
		if value:
			value_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		else:
			value_label.add_theme_color_override("font_color", Color.RED)
	else:
		value_label.add_theme_color_override("font_color", Color.WHITE)

	hbox.add_child(key_label)
	hbox.add_child(value_label)

	margin_container.add_child(hbox)
	vboxChild.add_child(margin_container)
