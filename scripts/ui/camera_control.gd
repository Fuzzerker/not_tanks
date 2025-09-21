extends Camera2D

# Camera movement settings
@export var pan_speed: float = 300.0
@export var smooth_movement: bool = true
@export var smoothing_factor: float = 0.1

# Zoom settings
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 3.0
@export var smooth_zoom: bool = true
@export var zoom_smoothing_factor: float = 0.15

# Target position and zoom for smooth movement
var target_position: Vector2
var target_zoom: Vector2

func _ready() -> void:
	# Initialize target position and zoom to current values
	target_position = global_position
	target_zoom = zoom
	
	# Connect to viewport size changed signal for responsive camera
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Optional: Set camera limits if needed
	# limit_left = -1000
	# limit_right = 1000
	# limit_top = -1000
	# limit_bottom = 1000

func _on_viewport_size_changed():
	# Adjust camera behavior when viewport size changes
	# This ensures the camera works properly with different window sizes
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Update zoom limits based on viewport size
	# Smaller viewports might need different zoom limits
	if viewport_size.x < 800 or viewport_size.y < 600:
		min_zoom = 0.3  # Allow more zoom out on small screens
	else:
		min_zoom = 0.2  # Standard zoom out limit

func _process(delta: float) -> void:
	handle_camera_input(delta)
	
	if smooth_movement:
		# Smooth camera movement
		global_position = global_position.lerp(target_position, smoothing_factor)
	else:
		# Direct camera movement
		global_position = target_position
	
	if smooth_zoom:
		# Smooth zoom
		zoom = zoom.lerp(target_zoom, zoom_smoothing_factor)
	else:
		# Direct zoom
		zoom = target_zoom

func handle_camera_input(delta: float) -> void:
	# Handle panning
	var input_vector: Vector2 = Vector2.ZERO
	
	# Check for arrow key inputs
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	
	# Normalize diagonal movement to maintain consistent speed
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		
		# Calculate movement (adjust speed based on zoom level for better feel)
		var movement: Vector2 = input_vector * pan_speed * delta * (1.0 / target_zoom.x)
		target_position += movement

func _input(event: InputEvent) -> void:
	# Handle zoom input
	if event is InputEventMouseButton:
		if event.pressed:
			var zoom_factor: float = 1.0
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_factor = 1.0 + zoom_speed
				zoom_in(zoom_factor)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_factor = 1.0 - zoom_speed
				zoom_out(zoom_factor)
	
	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				reset_camera()
			KEY_EQUAL, KEY_PLUS:  # + key for zoom in
				zoom_in(1.0 + zoom_speed)
			KEY_MINUS:  # - key for zoom out
				zoom_out(1.0 - zoom_speed)
			KEY_0:  # Reset zoom to 1.0
				reset_zoom()

func zoom_in(factor: float) -> void:
	var new_zoom: Vector2 = target_zoom * factor
	# Clamp to maximum zoom
	if new_zoom.x <= max_zoom and new_zoom.y <= max_zoom:
		target_zoom = new_zoom

func zoom_out(factor: float) -> void:
	var new_zoom: Vector2 = target_zoom * factor
	# Clamp to minimum zoom
	if new_zoom.x >= min_zoom and new_zoom.y >= min_zoom:
		target_zoom = new_zoom

func reset_zoom() -> void:
	target_zoom = Vector2.ONE

func reset_camera() -> void:
	target_position = Vector2.ZERO
	target_zoom = Vector2.ONE
