extends Node

# Building manager handles building placement and construction
const Building = preload("res://scripts/resources/building.gd")
const WorkRequest = preload("res://scripts/resources/work_request.gd")

var buildings: Array[Building] = []

# Building type configurations
var building_configs = {
	"smithy": {
		"construction_effort": 100,
		"marker_scene": preload("res://preloads/building_smithy.tscn"),
		"dimensions": Vector2i(5, 3)  # 5x3 tiles
	},
	"house": {
		"construction_effort": 100,
		"marker_scene": preload("res://preloads/building_house.tscn"),
		"dimensions": Vector2i(4, 4)  # 4x4 tiles
	}
}

func _get_assigned_house(character_name) -> Building:
	for bld in buildings:
		if bld.entity_type == EntityTypes.EntityType.HOUSE:
			if bld.construction_complete and bld.assigned_to == character_name:
				return bld
				
	for bld in buildings:
		if bld.entity_type == EntityTypes.EntityType.HOUSE:
			if bld.construction_complete and  bld.assigned_to == "":
				bld.assigned_to = character_name
				return bld 
	return null

func _register_building(building: Building) -> void:
	buildings.append(building)
	InformationRegistry._register(building)

func _get_building_config(building_type: String) -> Dictionary:
	return building_configs.get(building_type, {"construction_effort": 100, "marker_scene": preload("res://preloads/building_smithy.tscn"), "dimensions": Vector2i(4, 4)})

# Configure building sprite atlas based on dimensions
func _configure_building_sprite(marker: Sprite2D, building_type: String) -> void:
	var config = _get_building_config(building_type)
	var dimensions = config.get("dimensions", Vector2i(4, 4))
	
	# Set atlas texture region based on building dimensions
	# The region size should match the tile dimensions (32 pixels per tile)
	var tile_size = 32
	var region_size = Vector2(dimensions.x * tile_size, dimensions.y * tile_size)
	
	# Create or modify the atlas texture
	if marker.texture is AtlasTexture:
		var atlas_texture = marker.texture as AtlasTexture
		atlas_texture.region.size = region_size
	else:
		# If it's not an AtlasTexture, create one
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = marker.texture
		atlas_texture.region = Rect2(Vector2.ZERO, region_size)
		marker.texture = atlas_texture

# Create construction work for a building
func _create_construction_work(building: Building) -> void:
	var terrain_gen = _get_terrain_gen()
	if terrain_gen == null:
		return
	
	# Delegate to terrain generator to create construction work with icons
	terrain_gen._create_building_construction_work(building)

# Handle completion of construction work on a single tile
func _complete_construction_work(building: Building, _completed_cell: Vector2i) -> void:
	if building == null:
		return
	
	# Check if all construction work for this building is complete
	var all_complete = true
	for cell in building.occupied_cells:
		if WorkQueue._has_work(cell):
			all_complete = false
			break
	
	if all_complete:
		# All construction complete - show the marker
		building.construction_complete = true
		
		# Show the marker if it exists (it should be hidden)
		if building.marker != null:
			building.marker.modulate.a = 1
		
		

# Helper to get terrain generator
func _get_terrain_gen():
	var root: Node = get_tree().current_scene
	if root != null:
		# Look for the Main scene first
		if root.has_method("load_scene"):  # This is the Main scene
			# Access the current game scene through main's current_scene
			if "current_scene" in root and root.current_scene != null:
				var game_scene: Node = root.current_scene
				# Try to find TileMapLayer in the game scene
				var terrain_gen: Node = game_scene.get_node_or_null("TileMapLayer")
				if terrain_gen is TileMapLayer:
					return terrain_gen
		else:
			# We're directly in the game scene, look for TileMapLayer
			var terrain_gen: Node = root.get_node_or_null("TileMapLayer")
			if terrain_gen is TileMapLayer:
				return terrain_gen
	
	return null

# Serialization methods
func serialize() -> Dictionary:
	var building_data = []
	for building in buildings:
		building_data.append(building.serialize())
	
	return {
		"buildings": building_data
	}

func deserialize(data: Dictionary) -> void:
	buildings.clear()
	
	if data.has("buildings"):
		for building_data in data.buildings:
			var building = Building.new()
			building.deserialize(building_data)
			_register_building(building)

# Helper method for save system
func _get_all_buildings() -> Array[Building]:
	return buildings.duplicate()

# Helper method for save system
func _clear_all_buildings() -> void:
	buildings.clear()
