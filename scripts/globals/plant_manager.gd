extends Node

# Import classes
const EntityTypes = preload("res://scripts/globals/entity_types.gd")


var _plants: Array[Plant] = []

var grow_interval: float = .1

# Internal timer
var _time_accumulator: float = 0.0

func _ready() -> void:
	randomize()

func _get_closest_plant(pos: Vector2) -> Plant:
	return SpatialUtils.find_closest_entity(_plants, pos) as Plant

# Get closest crop (excluding arbols) - for animals to eat
func _get_closest_crop(pos: Vector2) -> Plant:
	return SpatialUtils.find_closest_by_type(_plants, pos, EntityTypes.EntityType.CROP) as Plant

func _process(delta: float) -> void:
	# delta is already scaled by Engine.time_scale
	_time_accumulator += delta
	
	if _time_accumulator >= grow_interval:
		_time_accumulator -= grow_interval
		_gro_all()

func _register(plant: Plant) -> void:

	InformationRegistry._register(plant)
	_plants.push_back(plant)
	

func _update_plant_sprite(plant: Plant) -> void:
	var mrkr: Sprite2D = plant.marker
	
	# Handle different plant types differently
	if plant.entity_type == EntityTypes.EntityType.ARBOL:
		# Arbols scale instead of changing sprite
		if plant.has_method("update_scale"):
			plant.update_scale()
	else:
		# Crops change sprite based on health (existing logic)
		var health_level: int = int(plant.health / 25) + 1  # Every 25 health units = 1 sprite level
		var atlas_y_offset: int = health_level * 16  # 16 pixels per level
		
		# Calculate the base position (assuming sprite starts at top of atlas)
		var base_y: int = 0  # Adjust this based on your sprite atlas layout
		mrkr.texture.region = Rect2(
			Vector2(mrkr.texture.region.position.x, base_y + atlas_y_offset),
			mrkr.texture.region.size
		)

func _consume_plant(plant):
	if plant not in _plants:
		return plant
	if plant == null:
		_plants.erase(plant)
	plant.health -= 1
	_update_plant_sprite(plant)

func _gro_all() -> void:
	for plant in _plants:
		# Handle arbols differently from crops
		if plant.entity_type == EntityTypes.EntityType.ARBOL:
			_grow_arbol(plant)
		else:
			_grow_crop(plant)
		
		# Remove dead plants
		if plant.health <= 0:
			_plants.erase(plant)
			plant.marker.queue_free()
			plant.queue_free()

func _grow_arbol(arbol: Plant) -> void:
	# Arbols grow without water and don't generate harvest requests
	if arbol.total_gro < arbol.max_total_gro:
		arbol.total_gro += 1
		arbol.health += 1
		
		# Cap health at maximum
		if arbol.health > arbol.max_health:
			arbol.health = arbol.max_health
		
		# Update arbol scale
		_update_plant_sprite(arbol)

func _grow_crop(plant: Plant) -> void:
	# Check if crop is ready for harvest (at full growth)
	if plant.total_gro >= plant.max_total_gro:
		var req := WorkRequest.new()
		req.type = "harvest"
		req.cell = plant.cell
		req.position = plant.position
		req.effort = 100
		
		# Store command data for serialization
		req.command_data = {
			"plant_id": plant.get_instance_id()
		}
		
		req.on_complete = func():
			Resources.food += int(plant.health / 10)
			Resources.seeds += randi_range(1, 3)
			plant.marker.queue_free()
			plant.queue_free()
			_plants.erase(plant)
		WorkQueue._add_work(req)
		return

	# If crop has water, grow it
	if plant.agua > 0:
		plant.total_gro += 1
		if plant.total_gro <= plant.max_total_gro:	
			plant.health += 1
			plant.agua -= 1
			# Cap health at maximum
			if plant.health > plant.max_health:
				plant.health = plant.max_health
			# Update sprite based on new health
			_update_plant_sprite(plant)
	else:
		# Request water if crop has none
		var req := WorkRequest.new()
		req.type = "agua"
		req.cell = plant.cell
		req.position = plant.position
		req.effort = 600
		
		# Store command data for serialization
		req.command_data = {
			"plant_id": plant.get_instance_id()
		}
		
		req.on_complete = func():
			if plant != null:
				plant.agua = 6
		WorkQueue._add_work(req)

# Helper method for save system to get all plants
func _get_all_plants() -> Array[Plant]:
	return _plants.duplicate()

# Helper method for save system to clear all plants
func _clear_all_plants() -> void:
	# First queue_free all plant markers and plants
	for plant in _plants:
		if plant.marker != null:
			plant.marker.queue_free()
		plant.queue_free()
	# Clear the array
	_plants.clear()
