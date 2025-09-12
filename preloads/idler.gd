extends "res://scripts/mover.gd"

const MAX_OFFSET := 50

var pause_time: float = 0.0
var is_idle = true

func _ready():
	speed = 20
	_pick_new_idle_target()
	

func _process(delta: float):
	
	if !is_idle:
		return
	if log:
		print("idle_process")
	if pause_time > 0:
		pause_time -= delta
		return

	if _has_arrived(1):
		pause_time = randf() * 1.0
		_pick_new_idle_target()
	else:
		_move_toward(delta)

func _pick_new_idle_target():
	if log:
		print("_pick_new_idle_target")
	var offset = Vector2(randf_range(-MAX_OFFSET, MAX_OFFSET), randf_range(-MAX_OFFSET, MAX_OFFSET))
	target_position = position + offset
