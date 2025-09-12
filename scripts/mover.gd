extends Sprite2D

# Base movement speed (can be overridden in child scripts)
var speed: float = 100.0
# Target position for movement
var target_position: Vector2

var log = false

func _move_toward(delta: float) -> void:
	var direction = target_position - position
	var distance = direction.length()
	
	if distance > 0.01:
		# Flip sprite based on horizontal direction
		if direction.x > 0:
			flip_h = true
		elif direction.x < 0:
			flip_h = false

		# Smooth movement
		direction = direction.normalized()
		position += direction * speed * delta

func _has_arrived(threshold: float = 1.0) -> bool:
	var has_arrived = position.distance_squared_to(target_position) < threshold * threshold
	position.distance_squared_to(target_position) < threshold * threshold
	if log:
		print("has_arrived= ", has_arrived, " because I am at ", position, " and targe is at ", target_position )
	return has_arrived
