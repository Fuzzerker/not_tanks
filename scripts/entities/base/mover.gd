extends "res://scripts/entities/base/savable.gd"

var speed: float = 100.0
var target_position: Vector2
var is_moving: bool = false


func _process(delta: float) -> void:
	# Continuous movement - this runs every frame for smooth movement
	if is_moving:
		_move_toward(delta)

func _move_toward(delta: float = 0.0) -> void:
	var direction: Vector2 = target_position - position
	var distance: float = direction.length()
	
	if distance > 1:
		# Flip sprite based on horizontal direction
		flip_h = direction.x > 0

		# Use provided delta or get frame delta for smooth movement
		var move_delta = delta if delta > 0.0 else get_process_delta_time()
		var dir_norm = direction.normalized() 
		var pos_update = dir_norm * speed * move_delta
		position += pos_update
	else:
		# We've arrived, stop moving
		is_moving = false

func _has_arrived(threshold: float) -> bool:
	threshold *= Engine.time_scale
	var has_arrived: bool = position.distance_squared_to(target_position) < threshold * threshold
	return has_arrived

func _set_target_position(new_target: Vector2) -> void:
	target_position = new_target
	is_moving = true
