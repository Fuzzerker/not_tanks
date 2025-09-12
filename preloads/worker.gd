extends "res://preloads/idler.gd"

var active_work = null
var effort = 10
var stamina = 100000
var max_stamina = 100000

var rest_distance = 60

var action = "idle"

func _ready():
	#log = true
	is_idle = true
	speed = 100.0
	CharacterRegistry._add_character({"ref":self, "type":"worker"})


func _process(delta: float):
	if log:
		print("process ", target_position)
	if stamina <= 10:
		if action != "rest":
			if log:
				print("trying to find closest cleric")
			var closest_cleric = CharacterRegistry._get_closest_cleric(position)
			if closest_cleric != null:
				if log:
					print("foudn closest cleric")
				target_position = closest_cleric
				action = "rest"
			else:
				if log:
					print("no closest cleric idling")
				super(delta)
		
	else: if not active_work:
		_find_work()
	var target_dist = .55
	if action == "rest":
		target_dist = rest_distance
	if _has_arrived(target_dist):
		if log:
			print("arrived")
		if action == "rest":
			var closest_cleric = CharacterRegistry._get_closest_cleric(position)
			if closest_cleric != null:
				if log:
					print("foudn closest cleric")
				target_position = closest_cleric
				action = "rest"
			stamina += 10
			if stamina >= max_stamina:
				stamina = max_stamina
				action = "idle"
				is_idle = true
		else: if active_work:
			_do_work()
		else:
			super(delta)
	else:
		_move_toward(delta)
	
	
		
		

func _do_work():
	if stamina < 0:
		return
	if WorkQueue._do_work(active_work.cell, effort):
		active_work = null
	stamina -= effort

func _find_work() -> bool:
	if log:
		print("_find_work ")
	active_work = WorkQueue._claim_work(position)
	if active_work != null:
		print("found work ", active_work["type"])
		target_position = active_work.position
	return active_work != null
