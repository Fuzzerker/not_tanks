extends Sprite2D

var id = -1


var populating_keys: Array = []
var populating_data: Array = []
var populating_inddex = 0

var pop_ticks = 3
var cur_ticks = 0

func set_id(_id):
	id = _id
	
func _ready():
	if id == -1:
		id = IdGenerator.next_id()
	SaveSystem._register(self)
	

		
func populate_from(data:Dictionary):
	for key in data.keys():
		populating_keys.push_back(key)
		populating_data.push_back(data.get(key))
		
	while _populate_next():
		continue
		
	
	
			
func _populate_next() -> bool:
	
	if populating_inddex >= populating_keys.size():
		return false
		
	var prop_key = populating_keys[populating_inddex]
	var vec_props = []
	var color_props = []
	var props := {}
	for prop in get_property_list():
		if prop.type == TYPE_VECTOR2:
			vec_props.push_back(prop.name)
		if prop.type == TYPE_COLOR:
			color_props.push_back(prop.name)
			
		props[prop.name] = true
	
	if props.has(prop_key):
		var data = populating_data[populating_inddex]
		
		if vec_props.has(prop_key):
			var nums = _parse_paren_formatted_values(data)
			data = Vector2(nums[0], nums[1])
		if color_props.has(prop_key):
			var nums = _parse_paren_formatted_values(data)
			data = Color(nums[0], nums[1], nums[2], nums[3])
		
		if prop_key == "position":
			print("setting positiong to ", data)
		set(prop_key, data)
		
			
	
	populating_inddex+=1
	
	return populating_inddex < populating_keys.size()

func _parse_paren_formatted_values(str:String) -> Array:
	str=str.replace("(", "")
	str=str.replace(")", "")
	
	var nums = str.split(",")
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
	"state_machine"
]
			
func get_info():
	var dict := {}
	for prop in get_property_list():
		
		var name = prop.name
		if props_to_ignore.has(name):
			continue
		var val = get(name)
		if val != null:
			dict[name]=val
				
	return dict
