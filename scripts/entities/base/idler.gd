extends "res://scripts/entities/base/mover.gd"

var MAX_OFFSET = 50

var pause_time: float = 0.0
var idle_origin: Vector2

func _ready():
	super._ready()
	speed = 20
	_start_idle()
	

func _process(delta: float):
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
	var idle_offset = Vector2(randf_range(-MAX_OFFSET, MAX_OFFSET), randf_range(-MAX_OFFSET, MAX_OFFSET))
	target_position = idle_origin + idle_offset

func _start_idle():
	idle_origin = position
	_pick_new_idle_target()

# Serialization methods
func serialize() -> Dictionary:
	var data = super.serialize()
	data["MAX_OFFSET"] = MAX_OFFSET
	data["pause_time"] = pause_time
	data["idle_origin"] = {"x": idle_origin.x, "y": idle_origin.y}
	return data

func deserialize(data: Dictionary):
	super.deserialize(data)
	if data.has("MAX_OFFSET"):
		MAX_OFFSET = data.MAX_OFFSET
	if data.has("pause_time"):
		pause_time = data.pause_time
	if data.has("idle_origin"):
		idle_origin = Vector2(data.idle_origin.x, data.idle_origin.y)
