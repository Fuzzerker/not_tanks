extends Node

var _plants:Array = []

var ticks = 0
var gro_ticks = 10
func _process(delta: float) -> void:
	ticks+=1
	if ticks >= gro_ticks:
		ticks = 0
		_gro_all()
		
func _register(plant):
	print("registering plant")
	plant["gro_required"] = 10
	plant["current_gro"] = 0
	plant["final_phase"] = 4
	plant["current_phase"] = 0
	plant["has_agua"] = false
	_plants.push_back(plant)
	
func _gro_all():
	for plant in _plants:
		if plant["current_phase"]==4:
			var request = {
				"type": "harvest",
				"cell": plant["cell"],
				"position": plant["position"],
				"status": "pending",
				"effort": 100,
				"on_complete": func():
					print("harvested")
					Resources.food += 1
					plant.marker.queue_free()
					_plants.erase(plant)
			}
			WorkQueue._add_work(request)
			continue
		if plant["has_agua"]:
			print("plant has agua.  Groing ",plant["current_gro"])
			plant["current_gro"]+=1
			print("plant has agua.  groed ",plant["current_gro"], " needs ",plant["gro_required"])
			plant["has_agua"] = false
			if plant["current_gro"] >= plant["gro_required"]:
				print("plant has grone to next phase")
				plant["current_gro"] = 0
				plant["current_phase"] += 1
				var mrkr = plant["marker"]
				mrkr.texture.region = Rect2(mrkr.texture.region.position + Vector2(0, 16), mrkr.texture.region.size)

		else:
			var request = {
				"type": "agua",
				"cell": plant["cell"],
				"position": plant["position"],
				"status": "pending",
				"effort": 100,
				"on_complete": func():
					print("adding agua on_complete")
					plant["has_agua"]=true
			}
			WorkQueue._add_work(request)
			
	
	
