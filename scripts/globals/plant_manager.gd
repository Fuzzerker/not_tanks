extends Node

# Import classes


var _plants: Array[Plant] = []

var grow_interval: float = .1

# Internal timer
var _time_accumulator: float = 0.0

func _ready():
	randomize()

func _get_closest_plant(pos: Vector2) -> Plant:
	var closest_plant: Plant = null
	var closest_dist := INF

	for plant in _plants:
		var dist = pos.distance_squared_to(plant.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_plant = plant
	
	return closest_plant

func _process(delta: float) -> void:
	# delta is already scaled by Engine.time_scale
	_time_accumulator += delta
	
	if _time_accumulator >= grow_interval:
		_time_accumulator -= grow_interval
		_gro_all()

func _register(plant: Plant) -> void:

	print("registering plant")
	InformationRegistry._register(plant)
	_plants.push_back(plant)
	

func _update_plant_sprite(plant: Plant) -> void:
	var mrkr = plant.marker
	var health_level = int(plant.health / 25) +1  # Every 25 health units = 1 sprite level
	var atlas_y_offset = health_level * 16  # 16 pixels per level
	
	# Calculate the base position (assuming sprite starts at top of atlas)
	var base_y = 0  # Adjust this based on your sprite atlas layout
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
		# Check if plant is ready for harvest (at full health)
		if plant.health >= plant.max_health:
			var req := WorkRequest.new()
			req.type = "harvest"
			req.cell = plant.cell
			req.position = plant.position
			req.effort = 100
			req.on_complete = func():
				print("harvested")
				Resources.food += 1
				Resources.seeds += randi_range(1, 3)
				plant.marker.queue_free()
				plant.queue_free()
				_plants.erase(plant)
			WorkQueue._add_work(req)
			continue

		# If plant has water, grow it
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
			# Request water if plant has none
			var req := WorkRequest.new()
			req.type = "agua"
			req.cell = plant.cell
			req.position = plant.position
			req.effort = 600
			req.on_complete = func():
				if plant != null:
					plant.agua = 6
			WorkQueue._add_work(req)
		if plant.health <= 0:
			_plants.erase(plant)
			plant.marker.queue_free()
			plant.queue_free()
