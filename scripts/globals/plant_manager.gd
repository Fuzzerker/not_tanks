extends Node
const EntityTypes = preload("res://scripts/globals/entity_types.gd")


var _plants: Array[Plant] = []

func flush():
	_plants = []

func _ready() -> void:
	TimeManager._register(_process_tick)
	randomize()

func _get_closest_plant(pos: Vector2) -> Plant:
	return SpatialUtils.find_closest_entity(_plants, pos) as Plant

# Get closest crop (excluding arbols) - for animals to eat
func _get_closest_crop(pos: Vector2) -> Plant:
	return SpatialUtils.find_closest_by_type(_plants, pos, EntityTypes.EntityType.CROP) as Plant

func _process_tick() -> void:

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
		
		var plant_gro_perc = float(plant.health) / float(plant.max_health) * 100
		print("plant_gro_perc ", plant_gro_perc)
		var health_level: int = int(plant_gro_perc / 25) + 1  # Every 25 health units = 1 sprite level
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
		
		if plant == null:
			_plants.erase(plant)
			continue
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
	else: if not plant.agua_request_generated:
		# Request water if crop has none
		plant.agua_request_generated = true
		WorkRequest.new("agua", plant.cell, plant.position, "res://preloads/agua_icon.tscn", 600)

		
	if plant.total_gro >= plant.max_total_gro:
		WorkRequest.new("harvest", plant.cell, plant.position)
