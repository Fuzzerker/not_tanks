extends Node

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
	
	
func _drain_plant(plant:Plant) -> Plant:
	if !_plants.has(plant):
		return null
	plant.current_gro -= 1
	if plant.current_gro < 0:
		plant.current_phase -= 1
		if plant.current_phase < 0:
			_plants.erase(plant)
			plant.queue_free()
			return null
		
		plant.current_gro = plant.gro_required -1
		plant.current_phase -= 1
		var mrkr = plant.marker
		mrkr.texture.region = Rect2(
			mrkr.texture.region.position + Vector2(0, -16),
			mrkr.texture.region.size
		)
		
	return plant

func _gro_all() -> void:
	for plant in _plants:
		if plant.current_phase == plant.final_phase:
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
				_plants.erase(plant)
			WorkQueue._add_work(req)
			continue

		if plant.aqua > 0:
			plant.current_gro += 1
			plant.aqua -= 1
			if plant.current_gro >= plant.gro_required:
				plant.current_gro = 0
				plant.current_phase += 1
				var mrkr = plant.marker
				mrkr.texture.region = Rect2(
					mrkr.texture.region.position + Vector2(0, 16),
					mrkr.texture.region.size
				)
		else:
			var req := WorkRequest.new()
			req.type = "agua"
			req.cell = plant.cell
			req.position = plant.position
			req.effort = 600
			req.on_complete = func():
				if plant != null:
					plant.aqua = 6
			WorkQueue._add_work(req)
