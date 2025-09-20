extends Resource
class_name WorkRequest

var type: String
var cell: Vector2i
var position: Vector2
var status: String = "pending"
var effort: int
var marker: Sprite2D = null
var marker_path: String
var marker_scale: Vector2 = Vector2.ZERO
var entity_type = EntityTypes.EntityType.WORKREQUEST

static func from_dict(dict: Dictionary) -> WorkRequest:
	var typed_dict = parse_dict_to_types(dict)
	return WorkRequest.new(typed_dict["type"],  typed_dict["cell"], 
	typed_dict["position"], typed_dict["marker_path"], typed_dict["effort"],
	typed_dict["marker_scale"]
	)
	
	
func queue_free():
	SaveSystem.remove_savable(self)

func _init(_type: String, _cell: Vector2i, _position: Vector2, 
_marker_path: String = "", _effort: int = 100, _marker_scale:Vector2 = Vector2(.5, .5)):
	type = _type
	cell = _cell
	position = _position
	marker_path = _marker_path
	effort = _effort
	marker_scale = _marker_scale
	if marker_path != "":
		marker = load(marker_path).instantiate() as Sprite2D
		WorkCallbackFactory._get_terrain_gen().add_child(marker)
		marker.position = position
		marker.scale = marker_scale

	WorkQueue._add_work(self)
	SaveSystem._register(self)

	
static func parse_dict_to_types(dict:Dictionary):
	var vec_props = []
	var color_props = []
	var parsed_dict := {}
	for item in dict:
		var data = dict.get(item)
		if item == "position" or item == "cell" or item == "marker_scale":
			var nums = _parse_paren_formatted_values(data)
			data = Vector2(nums[0], nums[1])
		parsed_dict.set(item, data)

	return parsed_dict
			

static func _parse_paren_formatted_values(str:String) -> Array:
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

func get_info():
	var dict := {}
	for prop in get_property_list():
		
		var name = prop.name
		var val = get(name)
		if val != null:
			dict[name]=val
				
	return dict
	
