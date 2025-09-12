extends Sprite2D

# Maximum distance from the current position for the idle movement
const MAX_OFFSET := 50
# Movement speed in pixels per second
const SPEED := 20

var target_position: Vector2
var pause_time: float = 0.0

func _ready():
	_pick_new_target()

func _process(delta: float):
	if pause_time > 0:
		# Wait while paused
		pause_time -= delta
		return

	# Move toward the target position
	var direction = target_position - position
	var distance = direction.length()
	
	# Flip the sprite based on horizontal direction
	if direction.x > 0:
		flip_h = true  # Facing right
	elif direction.x < 0:
		flip_h = false   # Facing left

	if distance < 1:
		# Arrived at the target, pause briefly
		pause_time = randf() * 1.0 # random pause < 1 second
		_pick_new_target()
	else:
		# Move smoothly toward target
		direction = direction.normalized()
		position += direction * SPEED * delta

func _pick_new_target():
	# Choose a random point near the current position
	var offset = Vector2(randf_range(-MAX_OFFSET, MAX_OFFSET), randf_range(-MAX_OFFSET, MAX_OFFSET))
	target_position = position + offset
