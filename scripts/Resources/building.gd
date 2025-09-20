extends Resource

class_name Building

const EntityTypes = preload("res://scripts/globals/entity_types.gd")

var building_type: String = ""
var position: Vector2
var construction_complete: bool = false
var entity_type: EntityTypes.EntityType
var marker: Sprite2D
var assigned_to = ""
var occupied_cells = []
var start_cell = null




func _init(_building_type: String, _start_cell: Vector2i, _position:Vector2, _construction_complete: bool,
 			_entity_type: EntityTypes.EntityType, _assigned_to: String ):
	building_type = _building_type
	position = _position
	construction_complete = _construction_complete
	entity_type = _entity_type
	assigned_to = _assigned_to
	start_cell = _start_cell
	
	match _building_type:
		"house":
			marker = preload("res://preloads/building_house.tscn").instantiate()
		"smithy":
			marker = preload("res://preloads/building_smithy.tscn").instantiate()
	
	var tex_size = marker.texture.get_size()
	var conf = BuildingManager._get_building_config(_building_type)
	occupied_cells = SpatialUtils.calculate_occupied_cells(start_cell, conf.get("dimensions"))
	var ne_x = (tex_size.x / 2) 
	var ne_y = (tex_size.y / 3) * -1
	
	marker.position = position + Vector2(ne_x, ne_y)
	# Make the marker 50% translucent until construction is complete
	if not construction_complete:
		marker.modulate.a = 0.5
	WorkCallbackFactory._get_terrain_gen().add_child(marker)
	BuildingManager._register_building(self)
	SaveSystem._register(self)
	
static func from_dict(dict: Dictionary) -> Building:
	var typed_dict = parse_dict_to_types(dict)
	return Building.new(typed_dict["building_type"], 
	typed_dict["start_cell"],
	typed_dict["position"], 
	typed_dict["construction_complete"],
	typed_dict["entity_type"],typed_dict["assigned_to"])
		
	
static func parse_dict_to_types(dict:Dictionary):
	var vec_props = []
	var color_props = []
	var parsed_dict := {}
	for item in dict:
		var data = dict.get(item)
		if item == "position" or item == "start_cell" or item == "marker_scale":
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
