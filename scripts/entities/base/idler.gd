extends "res://scripts/entities/base/living_entity.gd"

var MAX_OFFSET: int = 50

var pause_ticks: float = 3
var idle_origin: Vector2


func _ready() -> void:
	super._ready()
	speed = 20
	_start_idle()
	

func _process_tick(delta: float) -> bool:
	if super(delta):
		return true
		
	if pause_ticks > 0:
		pause_ticks -= 1
		return false

	if _has_arrived(3):
		pause_ticks = randi_range(2,8)
		_pick_new_idle_target()
	else:
		_move_toward(delta)
	
	return false
	

func _pick_new_idle_target() -> void:
	var idle_offset: Vector2 = Vector2(randf_range(-MAX_OFFSET, MAX_OFFSET), randf_range(-MAX_OFFSET, MAX_OFFSET))
	target_position = idle_origin + idle_offset

func _start_idle() -> void:
	idle_origin = position
	_pick_new_idle_target()

# Serialization methods
func serialize() -> Dictionary:
	var data = super.serialize()
	data["MAX_OFFSET"] = MAX_OFFSET
	#data["pause_time"] = pause_time
	data["idle_origin"] = SerializationUtils.serialize_vector2(idle_origin)
	return data

func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("MAX_OFFSET"):
		MAX_OFFSET = data.MAX_OFFSET
	if data.has("idle_origin"):
		idle_origin = SerializationUtils.deserialize_vector2(data.idle_origin)
