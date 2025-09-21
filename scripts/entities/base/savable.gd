extends Sprite2D
class_name Savable
var id = -1

var pop_ticks = 3
var cur_ticks = 0

func set_id(_id):
	id = _id
	
func _ready():
	if id == -1:
		id = IdGenerator.next_id()
	SaveSystem._register(self)
	

		
func populate_from(dict:Dictionary):
	var _vec_props = []
	var _color_props = []
	var _props := {}
	for prop in get_property_list():
		if dict.has(prop.name):
			var data = dict.get(prop.name)
			if prop.type == TYPE_VECTOR2:
				var nums = _parse_paren_formatted_values(data)
				data = Vector2(nums[0], nums[1])
			if prop.type == TYPE_COLOR:
				var nums = _parse_paren_formatted_values(data)
				data = Color(nums[0], nums[1], nums[2], nums[3])
			set(prop.name, data)
			

func _parse_paren_formatted_values(str_value:String) -> Array:
	str_value=str_value.replace("(", "")
	str_value=str_value.replace(")", "")
	
	var nums = str_value.split(",")
	var return_vals = []
	for num: String in nums:
		if num.contains("."):
			return_vals.push_back(num.to_float())
		else:
			return_vals.push_back(num.to_int())
	return return_vals
	
var props_to_ignore = [
	"props_to_ignore",
	"texture",
	"terrain_gen", 
	"transform",
	"vframes", 
	"script",
	"multiplayer",
	"global_transform",
	"global_position",
	"global_scale",
	"populating_inddex",
	"populating_data",
	"populating_keys",
	"state_machine",
	"house"
]
			
func get_info():
	var dict := {}
	for prop in get_property_list():
		
		var prop_name = prop.name
		if props_to_ignore.has(prop_name):
			continue
		var val = get(prop_name)
		if val != null:
			dict[prop_name]=val
				
	return dict

func get_ui_info():
	var all_props = get_property_list()
	var result: Dictionary = {}

	for prop in all_props:
		# Skip built-ins (they usually have "usage" flags and categories set)
		# User-defined variables will have the "script_var" flag
		if prop.has("usage") and (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			if prop.name == "entity_type":
				result[prop.name] = EntityTypes.type_to_string(get(prop.name))
			else:
				result[prop.name] = get(prop.name)

	return result

# Alias for UI compatibility
func _get_info():
	return get_info()
